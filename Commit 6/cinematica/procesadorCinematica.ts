import * as fs from 'fs';
import * as path from 'path';
import { spawnSync } from 'child_process';
import ffmpegPath from 'ffmpeg-static';

export interface OpcionesCinematica {
  rutaVideo: string;
  carpetaSalida?: string;
  prefijo?: string;
  ancho?: number;
  alto?: number;
  fps?: number;
  forzar?: boolean;
}

export interface MetadatosCinematica {
  videoOriginal: string;
  videoMtime: number;
  videoSize: number;
  prefijo: string;
  totalFrames: number;
  fps: number;
  intervaloMs: number;
  ancho: number;
  alto: number;
  rutaAudio: string | null;
  fechaGeneracion: string;
}

/**
 * Valida si las imágenes y el audio ya existen y están al día con respecto al video original.
 */
function esCacheValido(
  rutaVideo: string,
  carpetaSalida: string,
  prefijo: string,
  archivoInfo: string
): boolean {
  if (!fs.existsSync(rutaVideo) || !fs.existsSync(archivoInfo)) {
    return false;
  }

  try {
    const statsVideo = fs.statSync(rutaVideo);
    const info: MetadatosCinematica = JSON.parse(fs.readFileSync(archivoInfo, 'utf-8'));

    // Verificar si el video cambió en tamaño o fecha de modificación
    if (info.videoMtime !== statsVideo.mtimeMs || info.videoSize !== statsVideo.size) {
      return false;
    }

    // Verificar que todos los frames existan en disco
    for (let i = 0; i < info.totalFrames; i++) {
      const framePath = path.join(carpetaSalida, `${prefijo}${i}.png`);
      if (!fs.existsSync(framePath)) {
        return false;
      }
    }

    // Verificar el archivo de audio si correspondía
    if (info.rutaAudio) {
      const audioPath = path.join(carpetaSalida, path.basename(info.rutaAudio));
      if (!fs.existsSync(audioPath)) {
        return false;
      }
    }

    return true;
  } catch {
    return false;
  }
}

/**
 * Procesa un video individual: extrae frames PNG y audio MP3 optimizados para Wollok.
 */
export function procesarVideo(opciones: OpcionesCinematica): MetadatosCinematica | null {
  const rutaVideo = path.resolve(opciones.rutaVideo);
  if (!fs.existsSync(rutaVideo)) {
    console.error(`❌ Error: El video no existe en '${rutaVideo}'`);
    return null;
  }

  const nombreBase = path.basename(rutaVideo, path.extname(rutaVideo)).toLowerCase().replace(/[^a-z0-9_]/g, '_');
  const carpetaSalida = path.resolve(opciones.carpetaSalida || 'assets/cinematicas');
  const prefijo = opciones.prefijo || `${nombreBase}_`;
  const ancho = opciones.ancho || 750;
  const alto = opciones.alto || 750;
  const fps = opciones.fps || 8;
  const intervaloMs = Math.round(1000 / fps);
  const forzar = opciones.forzar || false;

  fs.mkdirSync(carpetaSalida, { recursive: true });

  const archivoInfo = path.join(carpetaSalida, `${prefijo.replace(/_$/, '')}.info.json`);

  // 1. Verificación de Caché Inteligente
  if (!forzar && esCacheValido(rutaVideo, carpetaSalida, prefijo, archivoInfo)) {
    const infoExistente: MetadatosCinematica = JSON.parse(fs.readFileSync(archivoInfo, 'utf-8'));
    console.log(`⚡ [Caché OK] '${path.basename(rutaVideo)}' ya está procesado (${infoExistente.totalFrames} frames a ${fps} FPS).`);
    return infoExistente;
  }

  console.log(`\n🎬 Procesando video: '${path.basename(rutaVideo)}'`);
  console.log(`   - Destino: ${carpetaSalida}`);
  console.log(`   - Resolución: ${ancho}x${alto} px | Tasa: ${fps} FPS (${intervaloMs} ms/frame)`);

  if (!ffmpegPath) {
    console.error('❌ Error: No se encontró el binario ejecutable de ffmpeg.');
    return null;
  }

  // 2. Extraer Audio a MP3
  const nombreAudio = `${prefijo}audio.mp3`;
  const rutaAudioDestino = path.join(carpetaSalida, nombreAudio);
  let tieneAudio = false;

  console.log('   -> Extrayendo pista de audio...');
  const resAudio = spawnSync(ffmpegPath, [
    '-y',
    '-i', rutaVideo,
    '-vn',
    '-ar', '44100',
    '-ac', '2',
    '-b:a', '128k',
    rutaAudioDestino
  ], { stdio: 'pipe' });

  if (resAudio.status === 0 && fs.existsSync(rutaAudioDestino) && fs.statSync(rutaAudioDestino).size > 1000) {
    tieneAudio = true;
    console.log(`   ✅ Audio generado: ${nombreAudio}`);
  } else {
    // Si no tiene pista de audio o falló la extracción, se elimina si quedó un archivo vacío
    if (fs.existsSync(rutaAudioDestino)) fs.unlinkSync(rutaAudioDestino);
    console.log('   ℹ️ Video sin pista de audio detectable (se reproducirá silenciado).');
  }

  // 3. Extraer Frames a PNG con numeración 0-indexada
  console.log('   -> Extrayendo y redimensionando frames...');
  const patronFrames = path.join(carpetaSalida, `${prefijo}%d.png`);
  const filtroVideo = `fps=${fps},scale=${ancho}:${alto}:flags=lanczos`;

  const resFrames = spawnSync(ffmpegPath, [
    '-y',
    '-i', rutaVideo,
    '-vf', filtroVideo,
    '-start_number', '0',
    patronFrames
  ], { stdio: 'pipe' });

  if (resFrames.status !== 0) {
    console.error('❌ Error al procesar frames con ffmpeg:', resFrames.stderr?.toString());
    return null;
  }

  // 4. Contar frames generados
  let totalFrames = 0;
  while (fs.existsSync(path.join(carpetaSalida, `${prefijo}${totalFrames}.png`))) {
    totalFrames++;
  }

  if (totalFrames === 0) {
    console.error('❌ No se generaron frames para el video.');
    return null;
  }

  console.log(`   ✅ Se generaron ${totalFrames} frames (${prefijo}0.png a ${prefijo}${totalFrames - 1}.png).`);

  // 5. Guardar manifiesto de metadatos para caché
  const statsVideo = fs.statSync(rutaVideo);
  const metadatos: MetadatosCinematica = {
    videoOriginal: path.relative(process.cwd(), rutaVideo).replace(/\\/g, '/'),
    videoMtime: statsVideo.mtimeMs,
    videoSize: statsVideo.size,
    prefijo,
    totalFrames,
    fps,
    intervaloMs,
    ancho,
    alto,
    rutaAudio: tieneAudio ? `cinematicas/${nombreAudio}` : null,
    fechaGeneracion: new Date().toISOString()
  };

  fs.writeFileSync(archivoInfo, JSON.stringify(metadatos, null, 2), 'utf-8');

  // 6. Imprimir snippet de Wollok listo para usar
  imprimirCodigoWollok(nombreBase, metadatos);

  return metadatos;
}

/**
 * Procesa automáticamente todos los videos encontrados en una carpeta dada.
 */
export function procesarCarpetaVideos(carpetaVideos: string, carpetaSalida: string = 'assets/cinematicas', fps: number = 8) {
  const dirVideos = path.resolve(carpetaVideos);
  if (!fs.existsSync(dirVideos)) {
    console.log(`ℹ️ Carpeta de videos no encontrada en '${dirVideos}'`);
    return;
  }

  const extensiones = new Set(['.mp4', '.mov', '.avi', '.mkv', '.webm']);
  const archivos = fs.readdirSync(dirVideos).filter(f => extensiones.has(path.extname(f).toLowerCase()));

  if (archivos.length === 0) {
    console.log(`ℹ️ No se encontraron videos para procesar en '${carpetaVideos}'.`);
    return;
  }

  console.log(`======================================================================`);
  console.log(`🎬 GESTOR DE CINEMÁTICAS EN TYPESCRIPT / NODE.JS`);
  console.log(`======================================================================`);
  console.log(`📁 Carpeta origen: ${carpetaVideos}`);
  console.log(`📁 Carpeta destino: ${carpetaSalida}`);

  for (const archivo of archivos) {
    const rutaVideo = path.join(dirVideos, archivo);
    const prefijo = `${path.basename(archivo, path.extname(archivo)).toLowerCase().replace(/[^a-z0-9_]/g, '_')}_`;
    procesarVideo({
      rutaVideo,
      carpetaSalida,
      prefijo,
      fps
    });
  }
}

function imprimirCodigoWollok(nombre: string, meta: MetadatosCinematica) {
  console.log('\n--- 📋 Código Wollok sugerido para tu juego ---');
  console.log(`object cinematica_${nombre} inherits ReproductorCinematica(`);
  console.log(`  x = 0,`);
  console.log(`  y = 0,`);
  console.log(`  width = 75,`);
  console.log(`  height = 75,`);
  console.log(`  prefijoFrames = "cinematicas/${meta.prefijo}",`);
  console.log(`  totalFrames = ${meta.totalFrames},`);
  console.log(`  intervaloMs = ${meta.intervaloMs},`);
  console.log(`  rutaAudio = ${meta.rutaAudio ? `"${meta.rutaAudio}"` : 'null'},`);
  console.log(`  idTick = "tick_${nombre}",`);
  console.log(`  image = "cinematicas/${meta.prefijo}0.png"`);
  console.log(`) {}\n`);
}

// Ejecución directa por CLI
if (require.main === module || process.argv[1]?.includes('procesadorCinematica')) {
  const args = process.argv.slice(2);
  const videoArg = args[0];
  const fpsArg = args[1] ? parseInt(args[1], 10) : 8;

  if (videoArg && fs.existsSync(videoArg) && fs.statSync(videoArg).isFile()) {
    procesarVideo({ rutaVideo: videoArg, fps: fpsArg });
  } else {
    // Procesa por defecto las carpetas comunes
    procesarCarpetaVideos('Prueba de videos', 'assets/cinematicas', fpsArg);
  }
}
