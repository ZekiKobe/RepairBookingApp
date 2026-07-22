export interface UploadResult {
  url: string;
  publicId?: string;
}

export interface StorageProvider {
  upload(buffer: Buffer, filename: string, mimetype: string, folder?: string): Promise<UploadResult>;
  delete(publicId: string): Promise<void>;
}
