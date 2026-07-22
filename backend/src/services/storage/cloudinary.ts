import { v2 as cloudinary } from 'cloudinary';
import { StorageProvider, UploadResult } from './types';
import { cloudinaryConfig } from '../../config/providers';

let _configured = false;

function configure() {
  if (_configured) return;
  if (!cloudinaryConfig.cloudName || !cloudinaryConfig.apiKey || !cloudinaryConfig.apiSecret) {
    throw new Error('Cloudinary config is incomplete. Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET in .env');
  }
  cloudinary.config({
    cloud_name: cloudinaryConfig.cloudName,
    api_key:    cloudinaryConfig.apiKey,
    api_secret: cloudinaryConfig.apiSecret,
    secure:     true,
  });
  _configured = true;
}

export class CloudinaryStorageProvider implements StorageProvider {
  constructor() {
    configure();
  }

  async upload(buffer: Buffer, filename: string, mimetype: string, folder = 'general'): Promise<UploadResult> {
    return new Promise((resolve, reject) => {
      const resourceType = mimetype.startsWith('image') ? 'image' : 'raw';
      const uploadStream = cloudinary.uploader.upload_stream(
        { folder: `repair_booking/${folder}`, resource_type: resourceType },
        (err, result) => {
          if (err || !result) return reject(err || new Error('Cloudinary upload failed'));
          resolve({ url: result.secure_url, publicId: result.public_id });
        }
      );
      uploadStream.end(buffer);
    });
  }

  async delete(publicId: string): Promise<void> {
    await cloudinary.uploader.destroy(publicId);
  }
}
