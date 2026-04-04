import { StatusBar } from 'expo-status-bar';
import { ActivityIndicator, Pressable, SafeAreaView, StyleSheet, Text, View } from 'react-native';
import { WebView } from 'react-native-webview';

export default function App() {
  const gaiaUrl = process.env.EXPO_PUBLIC_GAIA_URL?.trim() ?? '';
  const gaiaLabel = process.env.EXPO_PUBLIC_GAIA_LABEL?.trim() ?? 'Gaia';

  if (!gaiaUrl) {
    return (
      <SafeAreaView style={styles.shell}>
        <StatusBar hidden />
        <View style={styles.emptyState}>
          <Text style={styles.eyebrow}>Expo Go Setup</Text>
          <Text style={styles.title}>Add your stable Vercel URL</Text>
          <Text style={styles.body}>
            Set `EXPO_PUBLIC_GAIA_URL` in `.env` to your production or branch domain, then restart
            Expo.
          </Text>
          <View style={styles.codeCard}>
            <Text style={styles.code}>EXPO_PUBLIC_GAIA_URL=https://your-project.vercel.app</Text>
          </View>
          <Text style={styles.hint}>The README in this folder walks through the full mobile-preview flow.</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.shell}>
      <StatusBar hidden />
      <WebView
        source={{ uri: gaiaUrl }}
        style={styles.webview}
        originWhitelist={['*']}
        sharedCookiesEnabled
        setSupportMultipleWindows={false}
        allowsBackForwardNavigationGestures
        pullToRefreshEnabled
        bounces={false}
        startInLoadingState
        renderLoading={() => (
          <View style={styles.loadingState}>
            <ActivityIndicator size="small" color="#67765b" />
            <Text style={styles.loadingText}>Loading {gaiaLabel} preview…</Text>
          </View>
        )}
      />
      <View pointerEvents="box-none" style={styles.badgeWrap}>
        <Pressable style={styles.badge}>
          <Text style={styles.badgeLabel}>{gaiaLabel}</Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  shell: {
    flex: 1,
    backgroundColor: '#fefdf9',
  },
  webview: {
    flex: 1,
    backgroundColor: '#fefdf9',
  },
  loadingState: {
    flex: 1,
    backgroundColor: '#fefdf9',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
  },
  loadingText: {
    color: '#5b5c61',
    fontSize: 13,
  },
  badgeWrap: {
    position: 'absolute',
    top: 16,
    right: 16,
  },
  badge: {
    backgroundColor: 'rgba(252, 250, 240, 0.92)',
    borderRadius: 999,
    borderWidth: 1,
    borderColor: 'rgba(216, 201, 184, 0.95)',
    paddingHorizontal: 12,
    paddingVertical: 7,
  },
  badgeLabel: {
    color: '#67765b',
    fontSize: 12,
    fontWeight: '600',
  },
  emptyState: {
    flex: 1,
    paddingHorizontal: 28,
    alignItems: 'flex-start',
    justifyContent: 'center',
    backgroundColor: '#fefdf9',
  },
  eyebrow: {
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 1,
    textTransform: 'uppercase',
    color: '#67765b',
    marginBottom: 12,
  },
  title: {
    fontSize: 30,
    lineHeight: 34,
    fontWeight: '600',
    color: '#252024',
    marginBottom: 12,
  },
  body: {
    fontSize: 16,
    lineHeight: 24,
    color: '#5b5c61',
    marginBottom: 20,
  },
  codeCard: {
    width: '100%',
    backgroundColor: '#a6a5a1',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#d8c9b8',
    padding: 16,
    marginBottom: 14,
  },
  code: {
    fontSize: 13,
    lineHeight: 20,
    color: '#252024',
    fontFamily: 'Courier',
  },
  hint: {
    fontSize: 13,
    lineHeight: 19,
    color: '#7d7981',
  },
});
