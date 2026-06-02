import { XMLParser } from 'fast-xml-parser';

const BASE_URL = 'http://flibusta.net';
const PAGE_SIZE = 20;

export type Book = {
  id: string;
  title: string;
  authorName?: string;
  image?: string;
  description?: string;
  link?: string;
  allLinks: string[];
};

export type AuthorShort = {
  id: string;
  name: string;
  link?: string;
};

type XmlNode = Record<string, unknown>;

const parser = new XMLParser({
  ignoreAttributes: false,
  attributeNamePrefix: '@_',
  textNodeName: '#text',
  trimValues: true,
});

function asArray<T>(value: T | T[] | undefined | null): T[] {
  if (value == null) return [];
  return Array.isArray(value) ? value : [value];
}

function text(value: unknown): string | undefined {
  if (typeof value === 'string' || typeof value === 'number') return String(value);
  if (value && typeof value === 'object' && '#text' in value) return text((value as XmlNode)['#text']);
  return undefined;
}

function attr(node: unknown, name: string): string | undefined {
  if (!node || typeof node !== 'object') return undefined;
  const value = (node as XmlNode)[`@_${name}`];
  return typeof value === 'string' ? value : undefined;
}

function makeAbsoluteUrl(href: string | undefined): string | undefined {
  if (!href) return undefined;
  try {
    return new URL(href, BASE_URL).toString();
  } catch {
    return undefined;
  }
}

function normalizeLinks(entry: XmlNode): XmlNode[] {
  return asArray(entry.link as XmlNode | XmlNode[] | undefined);
}

function getAuthorName(entry: XmlNode): string | undefined {
  const authors = asArray(entry.author as XmlNode | XmlNode[] | undefined)
    .map((author) => text(author.name))
    .filter(Boolean);
  return authors.length ? `${authors.join(' ')} ` : undefined;
}

function getImage(links: XmlNode[]): string | undefined {
  const image = links.find((link) => {
    const rel = attr(link, 'rel') ?? '';
    const type = attr(link, 'type') ?? '';
    return rel.includes('image') || type.startsWith('image/');
  });
  return makeAbsoluteUrl(attr(image, 'href'));
}

function getDownloadLink(links: XmlNode[]): string | undefined {
  const priority = [
    'application/epub+zip',
    'application/zip',
    'application/djvu',
    'application/djvu+zip',
    'application/fb2+zip',
  ];

  for (const mediaType of priority) {
    const link = links.find((candidate) => attr(candidate, 'type') === mediaType);
    const url = makeAbsoluteUrl(attr(link, 'href'));
    if (url) return url;
  }

  const acquisition = links.find((candidate) => (attr(candidate, 'rel') ?? '').includes('acquisition'));
  return makeAbsoluteUrl(attr(acquisition, 'href'));
}

function stripHtml(html: string | undefined): string | undefined {
  if (!html) return undefined;
  return html
    .replace(/<br\s*\/?\s*>/gi, '\n')
    .replace(/<\/p>/gi, '\n\n')
    .replace(/<[^>]+>/g, '')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

async function fetchFeed(url: string): Promise<XmlNode> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`OPDS request failed: ${response.status} ${response.statusText}`);
  }
  const xml = await response.text();
  return parser.parse(xml) as XmlNode;
}

function feedEntries(feed: XmlNode): XmlNode[] {
  const root = feed.feed as XmlNode | undefined;
  return asArray(root?.entry as XmlNode | XmlNode[] | undefined);
}

function bookFromEntry(entry: XmlNode, index: number): Book {
  const links = normalizeLinks(entry);
  const title = text(entry.title)?.trim() || 'No title';
  const allLinks = links.map((link) => makeAbsoluteUrl(attr(link, 'href'))).filter(Boolean) as string[];

  return {
    id: text(entry.id) ?? `${title}-${index}-${allLinks[0] ?? ''}`,
    title,
    authorName: getAuthorName(entry),
    image: getImage(links),
    description: stripHtml(text(entry.content)) ?? 'No description',
    link: getDownloadLink(links),
    allLinks,
  };
}

function authorFromEntry(entry: XmlNode, index: number): AuthorShort {
  const links = normalizeLinks(entry);
  const catalogLink = links.find((link) => {
    const type = attr(link, 'type') ?? '';
    const rel = attr(link, 'rel') ?? '';
    return type.includes('opds-catalog') && !rel.includes('facet');
  }) ?? links[0];

  const name = text(entry.title) ?? 'No name';
  return {
    id: text(entry.id) ?? `${name}-${index}`,
    name,
    link: makeAbsoluteUrl(attr(catalogLink, 'href')),
  };
}

export async function searchByTitle(searchQuery: string, pageNumber = 0): Promise<Book[]> {
  const url = `${BASE_URL}/opds/search?searchType=books&pageNumber=${pageNumber}&searchTerm=${encodeURIComponent(searchQuery)}`;
  const feed = await fetchFeed(url);
  return feedEntries(feed).map(bookFromEntry);
}

export async function searchByAuthor(searchQuery: string, pageNumber = 0): Promise<AuthorShort[]> {
  const url = `${BASE_URL}/opds/search?searchType=authors&pageNumber=${pageNumber}&searchTerm=${encodeURIComponent(searchQuery)}`;
  const feed = await fetchFeed(url);
  return feedEntries(feed).map(authorFromEntry);
}

export async function getBooksByAuthor(authorLink: string, strictUrl = false, accumulator: Book[] = []): Promise<Book[]> {
  const requestUrl = strictUrl ? authorLink : `${authorLink}/alphabet`;
  const feed = await fetchFeed(requestUrl);
  const root = feed.feed as XmlNode | undefined;
  const books = feedEntries(feed).map(bookFromEntry);
  const nextLink = asArray(root?.link as XmlNode | XmlNode[] | undefined).find((link) => (attr(link, 'rel') ?? '').includes('next'));
  const nextUrl = makeAbsoluteUrl(attr(nextLink, 'href'));

  if (nextUrl) {
    return getBooksByAuthor(nextUrl, true, [...accumulator, ...books]);
  }

  return [...accumulator, ...books];
}

export { PAGE_SIZE };
