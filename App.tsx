import { StatusBar } from 'expo-status-bar';
import { useCallback, useEffect, useState } from 'react';
import {
  ActivityIndicator,
  FlatList,
  Image,
  Linking,
  Modal,
  Pressable,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import {
  AuthorShort,
  Book,
  PAGE_SIZE,
  getBooksByAuthor,
  searchByAuthor,
  searchByTitle,
} from './src/services/opds';

type SearchMode = 'book' | 'author';

function useDebouncedValue(value: string, delayMs: number) {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const timeout = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(timeout);
  }, [delayMs, value]);

  return debounced;
}

function EmptyImage() {
  return (
    <View style={styles.emptyImage}>
      <Text style={styles.emptyImageIcon}>▧</Text>
    </View>
  );
}

function BookRow({ book, onPress }: { book: Book; onPress: (book: Book) => void }) {
  return (
    <Pressable style={styles.row} onPress={() => onPress(book)}>
      {book.image ? <Image source={{ uri: book.image }} style={styles.thumb} /> : <EmptyImage />}
      <View style={styles.rowText}>
        <Text style={styles.title} numberOfLines={2}>{book.title}</Text>
        {book.authorName ? <Text style={styles.subtitle} numberOfLines={1}>{book.authorName}</Text> : null}
      </View>
    </Pressable>
  );
}

function AuthorRow({ author, onPress }: { author: AuthorShort; onPress: (author: AuthorShort) => void }) {
  return (
    <Pressable style={styles.row} onPress={() => onPress(author)}>
      <EmptyImage />
      <View style={styles.rowText}>
        <Text style={styles.title} numberOfLines={2}>{author.name}</Text>
      </View>
    </Pressable>
  );
}

function BookDetails({ book, onClose }: { book: Book; onClose: () => void }) {
  const openLink = useCallback((url?: string) => {
    if (url) Linking.openURL(url);
  }, []);

  return (
    <SafeAreaView style={styles.modalRoot}>
      <View style={styles.modalHeader}>
        <View />
        <Pressable onPress={onClose} hitSlop={12}>
          <Text style={styles.closeButton}>Close</Text>
        </Pressable>
      </View>
      <ScrollView contentContainerStyle={styles.detailsContent}>
        {book.image ? <Image source={{ uri: book.image }} style={styles.cover} resizeMode="contain" /> : null}
        <Text style={styles.detailsTitle}>{book.title}</Text>
        <Pressable
          style={[styles.downloadButton, !book.link && styles.downloadButtonDisabled]}
          disabled={!book.link}
          onPress={() => openLink(book.link)}
        >
          <Text style={styles.downloadButtonText}>Download</Text>
        </Pressable>
        <Text style={styles.description}>{book.description ?? 'No description'}</Text>
        <View style={styles.linksBlock}>
          {book.allLinks.map((link) => (
            <Pressable key={link} onPress={() => openLink(link)}>
              <Text style={styles.linkText}>{link}</Text>
            </Pressable>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

function AuthorDetails({ author, onClose, onBookPress }: { author: AuthorShort; onClose: () => void; onBookPress: (book: Book) => void }) {
  const [books, setBooks] = useState<Book[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    if (!author.link) return;

    setLoading(true);
    setError(null);
    getBooksByAuthor(author.link)
      .then((items) => {
        if (!cancelled) setBooks(items);
      })
      .catch((reason: Error) => {
        if (!cancelled) setError(reason.message);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [author.link]);

  return (
    <SafeAreaView style={styles.modalRoot}>
      <View style={styles.modalHeader}>
        <Text style={styles.modalTitle} numberOfLines={1}>{author.name}</Text>
        <Pressable onPress={onClose} hitSlop={12}>
          <Text style={styles.closeButton}>Close</Text>
        </Pressable>
      </View>
      {loading ? <ActivityIndicator style={styles.centered} /> : null}
      {error ? <Text style={styles.error}>{error}</Text> : null}
      <FlatList
        data={books}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => <BookRow book={item} onPress={onBookPress} />}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
        contentContainerStyle={styles.listContent}
      />
    </SafeAreaView>
  );
}

export default function App() {
  const [mode, setMode] = useState<SearchMode>('book');
  const [query, setQuery] = useState('');
  const debouncedQuery = useDebouncedValue(query, 200);
  const [books, setBooks] = useState<Book[]>([]);
  const [authors, setAuthors] = useState<AuthorShort[]>([]);
  const [loading, setLoading] = useState(false);
  const [fetchingMore, setFetchingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedBook, setSelectedBook] = useState<Book | null>(null);
  const [selectedAuthor, setSelectedAuthor] = useState<AuthorShort | null>(null);

  const title = mode === 'book' ? 'Books' : 'Authors';

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setError(null);

    const request = mode === 'book' ? searchByTitle(debouncedQuery) : searchByAuthor(debouncedQuery);
    request
      .then((items) => {
        if (cancelled) return;
        if (mode === 'book') setBooks(items as Book[]);
        else setAuthors(items as AuthorShort[]);
      })
      .catch((reason: Error) => {
        if (!cancelled) setError(reason.message);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [debouncedQuery, mode]);

  const fetchMore = useCallback(() => {
    if (mode !== 'book' || loading || fetchingMore || books.length === 0 || books.length % PAGE_SIZE !== 0) return;

    setFetchingMore(true);
    searchByTitle(debouncedQuery, books.length / PAGE_SIZE + 1)
      .then((nextBooks) => setBooks((current) => [...current, ...nextBooks]))
      .catch((reason: Error) => setError(reason.message))
      .finally(() => setFetchingMore(false));
  }, [books.length, debouncedQuery, fetchingMore, loading, mode]);

  return (
    <SafeAreaView style={styles.root}>
      <StatusBar style="auto" />
      <View style={styles.header}>
        <Text style={styles.screenTitle}>{title}</Text>
        <TextInput
          value={query}
          onChangeText={setQuery}
          placeholder="Search"
          autoCapitalize="none"
          autoCorrect={false}
          style={styles.searchInput}
        />
        <View style={styles.tabs}>
          <Pressable style={[styles.tab, mode === 'book' && styles.activeTab]} onPress={() => setMode('book')}>
            <Text style={[styles.tabText, mode === 'book' && styles.activeTabText]}>Books</Text>
          </Pressable>
          <Pressable style={[styles.tab, mode === 'author' && styles.activeTab]} onPress={() => setMode('author')}>
            <Text style={[styles.tabText, mode === 'author' && styles.activeTabText]}>Authors</Text>
          </Pressable>
        </View>
      </View>

      {loading ? <ActivityIndicator style={styles.centered} /> : null}
      {error ? <Text style={styles.error}>{error}</Text> : null}

      {mode === 'book' ? (
        <FlatList
          data={books}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => <BookRow book={item} onPress={setSelectedBook} />}
          ItemSeparatorComponent={() => <View style={styles.separator} />}
          contentContainerStyle={styles.listContent}
          onEndReached={fetchMore}
          onEndReachedThreshold={0.5}
          ListFooterComponent={fetchingMore ? <ActivityIndicator style={styles.footerLoader} /> : null}
        />
      ) : (
        <FlatList
          data={authors}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => <AuthorRow author={item} onPress={setSelectedAuthor} />}
          ItemSeparatorComponent={() => <View style={styles.separator} />}
          contentContainerStyle={styles.listContent}
        />
      )}

      <Modal visible={!!selectedBook} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setSelectedBook(null)}>
        {selectedBook ? <BookDetails book={selectedBook} onClose={() => setSelectedBook(null)} /> : null}
      </Modal>
      <Modal visible={!!selectedAuthor} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setSelectedAuthor(null)}>
        {selectedAuthor ? (
          <AuthorDetails
            author={selectedAuthor}
            onClose={() => setSelectedAuthor(null)}
            onBookPress={setSelectedBook}
          />
        ) : null}
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#f2f2f7' },
  header: { paddingHorizontal: 16, paddingBottom: 8, gap: 10 },
  screenTitle: { fontSize: 34, fontWeight: '700', color: '#111' },
  searchInput: { backgroundColor: '#fff', borderRadius: 10, paddingHorizontal: 12, paddingVertical: 10, fontSize: 16 },
  tabs: { flexDirection: 'row', backgroundColor: '#e5e5ea', borderRadius: 10, padding: 2 },
  tab: { flex: 1, paddingVertical: 8, alignItems: 'center', borderRadius: 8 },
  activeTab: { backgroundColor: '#fff' },
  tabText: { color: '#555', fontWeight: '600' },
  activeTabText: { color: '#111' },
  listContent: { margin: 16, padding: 12, backgroundColor: '#fff', borderRadius: 10 },
  row: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingVertical: 8 },
  rowText: { flex: 1 },
  title: { color: '#111', fontSize: 16 },
  subtitle: { color: 'rgba(0,0,0,0.4)', fontSize: 12, marginTop: 4 },
  thumb: { width: 40, height: 40, borderRadius: 4, backgroundColor: '#ddd' },
  emptyImage: { width: 40, height: 40, borderRadius: 4, backgroundColor: 'rgba(120,120,128,0.18)', alignItems: 'center', justifyContent: 'center' },
  emptyImageIcon: { color: 'rgba(60,60,67,0.6)', fontSize: 22 },
  separator: { height: StyleSheet.hairlineWidth, backgroundColor: '#c7c7cc' },
  centered: { marginTop: 24 },
  footerLoader: { paddingVertical: 16 },
  error: { color: '#b00020', margin: 16 },
  modalRoot: { flex: 1, backgroundColor: '#fff' },
  modalHeader: { padding: 16, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  modalTitle: { flex: 1, fontSize: 18, fontWeight: '600', paddingRight: 12 },
  closeButton: { color: '#007aff', fontSize: 17 },
  detailsContent: { alignItems: 'center', padding: 16, gap: 16 },
  cover: { width: 300, height: 300 },
  detailsTitle: { fontSize: 28, fontWeight: '600', textAlign: 'center' },
  downloadButton: { backgroundColor: '#007aff', paddingHorizontal: 18, paddingVertical: 10, borderRadius: 8 },
  downloadButtonDisabled: { opacity: 0.35 },
  downloadButtonText: { color: '#fff', fontWeight: '700' },
  description: { alignSelf: 'stretch', color: '#222', fontSize: 16, lineHeight: 22 },
  linksBlock: { alignSelf: 'stretch', gap: 8 },
  linkText: { color: '#007aff', textAlign: 'left' },
});
