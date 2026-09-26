const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

let ffmpegPath;
try {
  ffmpegPath = require('ffmpeg-static');
} catch (e) {
  ffmpegPath = null;
}

function esCacheValido(rutaVideo, carpetaSalida, prefijo, archivoInfo) {
  if (!fs.existsSync(rutaVideo) || !fs.existsSync(archivoInfo)) {
    return false;
  }
  try {
    const statsVideo = fs.statSync(rutaVideo);
    const info = JSON.parse(fs.readFileSync(archivoInfo, 'utf-8'));

    if (info.videoMtime !== statsVideo.mtimeMs || info.videoSize !== statsVideo.size) {
      return false;
    }

    if (info.totalFrames <= 0) return false;

    for (let i = 0; i < info.totalFrames; i++) {
      const framePath = path.join(carpetaSalida, `${prefijo}${i}.png`);
      if (!fs.existsSync(framePath)) {
        return false;
      }
    }

    if (info.rutaAudio) {
      const audioPath = path.join(carpetaSalida, path.basename(info.rutaAudio));
      if (!fs.existsSync(audioPath)) {
        return false;
      }
    }

    return true;
  } catch (e) {
    return false;
  }
}

function procesarVideo(opciones) {
  const rutaVideo = path.resolve(opciones.rutaVideo);
  if (!fs.existsSync(rutaVideo)) return null;

  const nombreBase = path.basename(rutaVideo, path.extname(rutaVideo)).toLowerCase().replace(/[^a-z0-9_]/g, '_');
  const carpetaSalida = path.resolve(opciones.carpetaSalida || 'assets/cinematicas');
  const prefijo = opciones.prefijo || `${nombreBase}_`;
  const ancho = opciones.ancho || 750;
  const alto = opciones.alto || 750;
  const fps = opciones.fps || 8;
  const intervaloMs = Math.round(1000 / fps);

  fs.mkdirSync(carpetaSalida, { recursive: true });

  const archivoInfo = path.join(carpetaSalida, `${prefijo.replace(/_$/, '')}.info.json`);

  if (esCacheValido(rutaVideo, carpetaSalida, prefijo, archivoInfo)) {
    const info = JSON.parse(fs.readFileSync(archivoInfo, 'utf-8'));
    console.log(`⚡ [Caché OK] '${path.basename(rutaVideo)}' ya está listo (${info.totalFrames} frames).`);
    return info;
  }

  console.log(`\n🎬 Generando frames para: '${path.basename(rutaVideo)}' (faltaban imágenes o video actualizado)`);
  
  if (!ffmpegPath) {
    console.error('❌ Error: ffmpeg-static no disponible.');
    return null;
  }

  // 1. Extraer Audio
  const nombreAudio = `${prefijo}audio.mp3`;
  const rutaAudioDestino = path.join(carpetaSalida, nombreAudio);
  let tieneAudio = false;

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
  } else if (fs.existsSync(rutaAudioDestino)) {
    fs.unlinkSync(rutaAudioDestino);
  }

  // 2. Extraer Frames
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
    console.error('❌ Error extrayendo frames:', resFrames.stderr ? resFrames.stderr.toString() : '');
    return null;
  }

  let totalFrames = 0;
  while (fs.existsSync(path.join(carpetaSalida, `${prefijo}${totalFrames}.png`))) {
    totalFrames++;
  }

  if (totalFrames === 0) return null;

  const statsVideo = fs.statSync(rutaVideo);
  const metadatos = {
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
  console.log(`   ✅ Listo: ${totalFrames} frames generados en assets/cinematicas/`);
  return metadatos;
}

function prepararTodas() {
  const dirVideos = path.resolve('Prueba de videos');
  if (!fs.existsSync(dirVideos)) return;

  const extensiones = new Set(['.mp4', '.mov', '.avi', '.mkv', '.webm']);
  const archivos = fs.readdirSync(dirVideos).filter(f => extensiones.has(path.extname(f).toLowerCase()));

  for (const archivo of archivos) {
    const rutaVideo = path.join(dirVideos, archivo);
    const prefijo = `${path.basename(archivo, path.extname(archivo)).toLowerCase().replace(/[^a-z0-9_]/g, '_')}_`;
    procesarVideo({
      rutaVideo,
      carpetaSalida: 'assets/cinematicas',
      prefijo,
      fps: 8
    });
  }
}

prepararTodas();
