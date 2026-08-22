async function processPetImage(file, size = 512) {
  const bitmap = await createImageBitmap(file);
  const source = drawToCanvas(bitmap);
  const cleaned = removeBackgroundFromCorners(source);
  const crop = findContentBounds(cleaned);
  const output = document.createElement("canvas");
  output.width = size;
  output.height = size;
  const ctx = output.getContext("2d");
  ctx.clearRect(0, 0, size, size);

  const padding = Math.round(size * 0.08);
  const target = size - padding * 2;
  const scale = Math.min(target / crop.width, target / crop.height);
  const width = crop.width * scale;
  const height = crop.height * scale;
  const x = (size - width) / 2;
  const y = (size - height) / 2;
  ctx.imageSmoothingEnabled = true;
  ctx.imageSmoothingQuality = "high";
  ctx.shadowColor = "rgba(130, 181, 247, .38)";
  ctx.shadowBlur = Math.round(size * 0.035);
  ctx.filter = "saturate(1.12) contrast(1.04)";
  ctx.drawImage(cleaned, crop.x, crop.y, crop.width, crop.height, x, y, width, height);
  ctx.filter = "none";
  ctx.shadowBlur = 0;
  drawStickerOutline(ctx, x, y, width, height, size);
  return output.toDataURL("image/png");
}

async function extractPetPalette(file) {
  const bitmap = await createImageBitmap(file);
  const canvas = drawToCanvas(bitmap);
  const cleaned = removeBackgroundFromCorners(canvas);
  const { data, width, height } = cleaned.getContext("2d").getImageData(0, 0, cleaned.width, cleaned.height);
  const buckets = new Map();
  for (let y = 0; y < height; y += 8) {
    for (let x = 0; x < width; x += 8) {
      const index = (y * width + x) * 4;
      if (data[index + 3] < 80) continue;
      const r = Math.round(data[index] / 32) * 32;
      const g = Math.round(data[index + 1] / 32) * 32;
      const b = Math.round(data[index + 2] / 32) * 32;
      const key = `${r},${g},${b}`;
      buckets.set(key, (buckets.get(key) || 0) + 1);
    }
  }
  const colors = [...buckets.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, 2)
    .map(([key]) => `rgb(${key})`);
  return { primary: colors[0] || "#72d6b2", secondary: colors[1] || "#82b5f7" };
}

function drawStickerOutline(ctx, x, y, width, height, size) {
  ctx.save();
  ctx.globalCompositeOperation = "destination-over";
  ctx.fillStyle = "rgba(255, 255, 255, .88)";
  const padding = Math.round(size * 0.018);
  ctx.beginPath();
  ctx.ellipse(x + width / 2, y + height / 2, width / 2 + padding, height / 2 + padding, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.restore();
}

function drawToCanvas(bitmap) {
  const canvas = document.createElement("canvas");
  canvas.width = bitmap.width;
  canvas.height = bitmap.height;
  const ctx = canvas.getContext("2d");
  ctx.drawImage(bitmap, 0, 0);
  return canvas;
}

function removeBackgroundFromCorners(canvas) {
  const ctx = canvas.getContext("2d");
  const image = ctx.getImageData(0, 0, canvas.width, canvas.height);
  const data = image.data;
  const samples = [
    colorAt(data, canvas.width, 0, 0),
    colorAt(data, canvas.width, canvas.width - 1, 0),
    colorAt(data, canvas.width, 0, canvas.height - 1),
    colorAt(data, canvas.width, canvas.width - 1, canvas.height - 1)
  ];

  for (let y = 0; y < canvas.height; y += 1) {
    for (let x = 0; x < canvas.width; x += 1) {
      const index = (y * canvas.width + x) * 4;
      const pixel = [data[index], data[index + 1], data[index + 2]];
      const distance = Math.min(...samples.map((sample) => colorDistance(pixel, sample)));
      if (distance < 42) data[index + 3] = 0;
      else if (distance < 72) data[index + 3] = Math.round(data[index + 3] * ((distance - 42) / 30));
    }
  }

  const output = document.createElement("canvas");
  output.width = canvas.width;
  output.height = canvas.height;
  output.getContext("2d").putImageData(image, 0, 0);
  return output;
}

function findContentBounds(canvas) {
  const { data, width, height } = canvas.getContext("2d").getImageData(0, 0, canvas.width, canvas.height);
  let minX = width;
  let minY = height;
  let maxX = 0;
  let maxY = 0;

  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const alpha = data[(y * width + x) * 4 + 3];
      if (alpha > 20) {
        minX = Math.min(minX, x);
        minY = Math.min(minY, y);
        maxX = Math.max(maxX, x);
        maxY = Math.max(maxY, y);
      }
    }
  }

  if (minX >= maxX || minY >= maxY) return { x: 0, y: 0, width, height };
  return { x: minX, y: minY, width: maxX - minX, height: maxY - minY };
}

function colorAt(data, width, x, y) {
  const index = (y * width + x) * 4;
  return [data[index], data[index + 1], data[index + 2]];
}

function colorDistance(a, b) {
  return Math.hypot(a[0] - b[0], a[1] - b[1], a[2] - b[2]);
}

window.processPetImage = processPetImage;
window.extractPetPalette = extractPetPalette;
