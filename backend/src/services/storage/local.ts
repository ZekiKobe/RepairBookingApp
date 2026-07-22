import fs from 'fs';
import path from 'path';
import { StorageProvider, UploadResult } from './types';

const UPLOAD_DIR = path.join(process.cwd(), 'uploads');

export class LocalStorageProvider implements StorageProvider {
  constructor() {
    if (!fs.existsSync(UPLOAD_DIR)) {
      fs.mkdirSync(UPLOAD_DIR, { recursive: true });
    }
  }

  async upload(buffer: Buffer, filename: string, _mimetype: string, folder = 'general'): Promise<UploadResult> {
    const dir = path.join(UPLOAD_DIR, folder);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

    const ext = path.extname(filename) || '.bin';
    const name = `${Date.now()}_${Math.random().toString(36).slice(2)}${ext}`;
    const filePath = path.join(dir, name);
    fs.writeFileSync(filePath, buffer);

    const baseUrl = process.env.BASE_URL || `http://localhost:${process.env.PORT || 5000}`;
    const url = `${baseUrl}/static/${folder}/${name}`;
    return { url, publicId: `${folder}/${name}` };
  }

  async delete(publicId: string): Promise<void> {
    const filePath = path.join(UPLOAD_DIR, publicId);
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
  }
}
