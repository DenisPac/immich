import { glob } from 'glob';
import { CrawlOptionsDto } from './library.dto';

// TODO: these extensions should be moved to somewhere else
const videos = ['mp4', 'webm', 'mov', '3gp', 'avi', 'm2ts', 'mts', 'mpg', 'flv', 'mkv', 'wmv'];

// Images
const heic = ['heic', 'heif'];
const jpeg = ['jpg', 'jpeg'];
const png = ['png'];
const gif = ['gif'];
const tiff = ['tif', 'tiff'];
const webp = ['webp'];
const dng = ['dng'];
const other = [
  '3fr',
  'ari',
  'arw',
  'avif',
  'cap',
  'cin',
  'cr2',
  'cr3',
  'crw',
  'dcr',
  'nef',
  'erf',
  'fff',
  'iiq',
  'jxl',
  'k25',
  'kdc',
  'mrw',
  'orf',
  'ori',
  'pef',
  'raf',
  'raw',
  'rwl',
  'sr2',
  'srf',
  'srw',
  'orf',
  'ori',
  'x3f',
];

export const ACCEPTED_FILE_EXTENSIONS = [
  ...videos,
  ...jpeg,
  ...png,
  ...heic,
  ...gif,
  ...tiff,
  ...webp,
  ...dng,
  ...other,
];

export class LibraryCrawler {
  public async findAllMedia(crawlOptions: CrawlOptionsDto): Promise<string[]> {
    const pathsToCrawl = crawlOptions.pathsToCrawl;

    let paths: string;
    if (!pathsToCrawl) {
      // No paths to crawl, return empty list
      return [];
    } else if (pathsToCrawl.length === 1) {
      paths = pathsToCrawl[0];
    } else {
      paths = '{' + pathsToCrawl.join(',') + '}';
    }

    paths = paths + '/**/*.{' + ACCEPTED_FILE_EXTENSIONS.join(',') + '}';

    return await glob(paths, { nocase: true, nodir: true, ignore: crawlOptions.excludePatterns }).then((crawledPaths) =>
      crawledPaths.sort(),
    );
  }
}