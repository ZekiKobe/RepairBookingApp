import { providers } from '../../config/providers';
import { StorageProvider } from './types';
import { LocalStorageProvider } from './local';
import { CloudinaryStorageProvider } from './cloudinary';

export { UploadResult } from './types';

let _instance: StorageProvider | null = null;

export function getStorageProvider(): StorageProvider {
  if (_instance) return _instance;
  switch (providers.storage) {
    case 'cloudinary': _instance = new CloudinaryStorageProvider(); break;
    default:           _instance = new LocalStorageProvider(); break;
  }
  console.log(`[Storage] Using provider: ${providers.storage}`);
  return _instance;
}
