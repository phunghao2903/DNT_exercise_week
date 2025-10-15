import React, { JSX, useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  Image,
  Modal,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { CameraView, useCameraPermissions } from 'expo-camera';
import * as FileSystem from 'expo-file-system/legacy';
import * as MediaLibrary from 'expo-media-library';
import * as Sharing from 'expo-sharing';
import AsyncStorage from '@react-native-async-storage/async-storage';

type FSDirs = { documentDirectory?: string | null; cacheDirectory?: string | null };
const FS = FileSystem as unknown as FSDirs;

type Note = {
  id: string;
  uri: string;
  caption: string;
  savedToLibraryUri: string | null;
};

const STORAGE_KEY = '@camera-notes/notes';

type FacingMode = 'back' | 'front';

const CameraNotesScreen = (): JSX.Element => {
  const cameraRef = useRef<CameraView | null>(null);
  const [activeTab, setActiveTab] = useState<'camera' | 'gallery'>('camera');
  const [cameraType, setCameraType] = useState<FacingMode>('back');
  const [notes, setNotes] = useState<Note[]>([]);
  const [cameraPermission, requestCameraPermission] = useCameraPermissions();
  const [mediaPermission, requestMediaLibraryPermission] = MediaLibrary.usePermissions();
  const [isLoading, setIsLoading] = useState(true);
  const [modalVisible, setModalVisible] = useState(false);
  const [pendingNote, setPendingNote] = useState<Note | null>(null);
  const [captionInput, setCaptionInput] = useState('');
  const [isEditing, setIsEditing] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const hasCameraAccess = useMemo(() => cameraPermission?.granted === true, [cameraPermission]);

  const loadNotes = useCallback(async () => {
    try {
      const stored = await AsyncStorage.getItem(STORAGE_KEY);
      if (stored) {
        setNotes(JSON.parse(stored) as Note[]);
      }
    } catch (error) {
      console.warn('Failed to load notes', error);
      setErrorMessage('Không thể tải dữ liệu đã lưu.');
    }
  }, []);

  const persistNotes = useCallback(async (nextNotes: Note[]) => {
    try {
      setNotes(nextNotes);
      await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(nextNotes));
    } catch (error) {
      console.warn('Failed to persist notes', error);
      setErrorMessage('Không thể lưu dữ liệu vào bộ nhớ.');
    }
  }, []);

  useEffect(() => {
    const bootstrapAsync = async () => {
      try {
        await Promise.allSettled([requestCameraPermission(), requestMediaLibraryPermission(), loadNotes()]);
      } finally {
        setIsLoading(false);
      }
    };

    void bootstrapAsync();
  }, [loadNotes, requestCameraPermission, requestMediaLibraryPermission]);

  const toggleCameraType = useCallback(() => {
    setCameraType((current) => (current === 'back' ? 'front' : 'back'));
  }, []);

  const scheduleCaptionModal = useCallback((note: Note, editing: boolean) => {
    setPendingNote(note);
    setCaptionInput(note.caption ?? '');
    setIsEditing(editing);
    setModalVisible(true);
  }, []);

  const takePhoto = useCallback(async (): Promise<Note | null> => {
    try {
      const photo = await cameraRef.current?.takePictureAsync({ quality: 0.8, skipProcessing: true });
      if (!photo?.uri) {
        return null;
      }
      const fileName = `note_${Date.now()}.jpg`;
      const baseDir = (FS.documentDirectory ?? FS.cacheDirectory)!;
      const destination = baseDir + fileName;

      await FileSystem.copyAsync({ from: photo.uri, to: destination });

      let savedToLibraryUri: string | null = null;
      if (mediaPermission?.granted) {
        try {
          const asset = await MediaLibrary.createAssetAsync(destination);
          savedToLibraryUri = asset?.uri ?? null;
        } catch (mediaError) {
          console.warn('Failed to save to media library', mediaError);
        }
      }

      return {
        id: fileName,
        uri: destination,
        caption: '',
        savedToLibraryUri,
      };
    } catch (error) {
      console.warn('Failed to take photo', error);
      setErrorMessage('Không thể chụp ảnh. Vui lòng thử lại.');
      return null;
    }
  }, [mediaPermission]);

  const handleCapture = useCallback(async () => {
    if (!hasCameraAccess) {
      const permission = await requestCameraPermission();
      if (!permission?.granted) {
        setErrorMessage('Ứng dụng cần quyền camera để chụp ảnh.');
        return;
      }
    }

    const draft = await takePhoto();
    if (!draft) {
      return;
    }

    scheduleCaptionModal(draft, false);
  }, [hasCameraAccess, requestCameraPermission, scheduleCaptionModal, takePhoto]);

  const closeModal = useCallback(
    async (shouldDiscardFile: boolean) => {
      if (shouldDiscardFile && pendingNote?.uri) {
        try {
          await FileSystem.deleteAsync(pendingNote.uri, { idempotent: true });
        } catch (error) {
          console.warn('Failed to delete temp file', error);
        }
      }
      setPendingNote(null);
      setCaptionInput('');
      setIsEditing(false);
      setModalVisible(false);
    },
    [pendingNote],
  );

  const saveNote = useCallback(async () => {
    if (!pendingNote) {
      return;
    }

    const caption = captionInput.trim();
    const noteToSave: Note = { ...pendingNote, caption };

    if (isEditing) {
      const nextNotes = notes.map((note) => (note.id === noteToSave.id ? noteToSave : note));
      await persistNotes(nextNotes);
    } else {
      const nextNotes = [noteToSave, ...notes];
      await persistNotes(nextNotes);
      setActiveTab('gallery');
    }

    await closeModal(false);
  }, [captionInput, closeModal, isEditing, notes, pendingNote, persistNotes]);

  const requestMediaPermissionIfNeeded = useCallback(async () => {
    let permission = mediaPermission;
    if (!permission?.granted) {
      permission = await requestMediaLibraryPermission();
    }
    return permission?.granted ?? false;
  }, [mediaPermission, requestMediaLibraryPermission]);

  const saveToLibrary = useCallback(
    async (note: Note) => {
      const granted = await requestMediaPermissionIfNeeded();
      if (!granted) {
        Alert.alert('Quyền truy cập', 'Không thể lưu vì thiếu quyền truy cập thư viện.');
        return;
      }

      try {
        const asset = await MediaLibrary.createAssetAsync(note.uri);
        const updatedNotes = notes.map((item) =>
          item.id === note.id ? { ...item, savedToLibraryUri: asset?.uri ?? item.savedToLibraryUri ?? null } : item,
        );

        await persistNotes(updatedNotes);
        Alert.alert('Thành công', 'Ảnh đã được lưu vào thư viện.');
      } catch (error) {
        console.warn('Failed to save to library', error);
        setErrorMessage('Không thể lưu ảnh vào thư viện.');
      }
    },
    [notes, persistNotes, requestMediaPermissionIfNeeded],
  );

  const shareNote = useCallback(async (note: Note) => {
    try {
      const available = await Sharing.isAvailableAsync();
      if (!available) {
        Alert.alert('Chia sẻ', 'Chức năng chia sẻ không khả dụng trên thiết bị này.');
        return;
      }

      await Sharing.shareAsync(note.uri);
    } catch (error) {
      console.warn('Failed to share note', error);
      setErrorMessage('Không thể chia sẻ ảnh.');
    }
  }, []);

  const deleteNote = useCallback(
    (note: Note) => {
      Alert.alert('Xoá ảnh', 'Bạn có chắc muốn xoá ảnh này?', [
        { text: 'Hủy', style: 'cancel' },
        {
          text: 'Xoá',
          style: 'destructive',
          onPress: async () => {
            const filteredNotes = notes.filter((item) => item.id !== note.id);
            await persistNotes(filteredNotes);

            try {
              await FileSystem.deleteAsync(note.uri, { idempotent: true });
            } catch (error) {
              console.warn('Failed to delete note file', error);
            }
          },
        },
      ]);
    },
    [notes, persistNotes],
  );

  const renderCameraSection = () => {
    if (!cameraPermission?.granted) {
      return null;
    }

    return (
      <View style={styles.cameraContainer}>
        <CameraView ref={cameraRef} style={styles.camera} facing={cameraType} ratio="16:9" />
        <View style={styles.cameraOverlay} pointerEvents="box-none">
          <TouchableOpacity style={styles.flipButton} onPress={toggleCameraType}>
            <Text style={styles.buttonText}>Flip</Text>
          </TouchableOpacity>
        </View>
        <TouchableOpacity style={styles.captureButton} onPress={handleCapture}>
          <Text style={styles.buttonText}>Chụp</Text>
        </TouchableOpacity>
      </View>
    );
  };

  const renderGalleryItem = ({ item }: { item: Note }) => (
    <View style={styles.noteCard}>
      <TouchableOpacity style={styles.photoWrapper} onPress={() => shareNote(item)}>
        <Image source={{ uri: item.uri }} style={styles.photo} />
      </TouchableOpacity>
      <Text style={styles.captionText}>{item.caption ? item.caption : 'Chưa có ghi chú'}</Text>
      <View style={styles.noteActions}>
        <TouchableOpacity style={styles.noteActionButton} onPress={() => scheduleCaptionModal(item, true)}>
          <Text style={styles.noteActionText}>Sửa</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.noteActionButton} onPress={() => saveToLibrary(item)}>
          <Text style={styles.noteActionText}>Lưu thư viện</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.noteActionButton} onPress={() => shareNote(item)}>
          <Text style={styles.noteActionText}>Chia sẻ</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.noteActionButton} onPress={() => deleteNote(item)}>
          <Text style={styles.noteActionText}>Xoá</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  const renderGallerySection = () => (
    <View style={styles.galleryContainer}>
      <FlatList
        data={notes}
        keyExtractor={(item) => item.id}
        contentContainerStyle={notes.length === 0 ? styles.emptyGallery : undefined}
        ListEmptyComponent={<Text style={styles.emptyText}>Chưa có ảnh nào</Text>}
        renderItem={renderGalleryItem}
      />
    </View>
  );

  if (isLoading || !cameraPermission) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <StatusBar style="light" />
        <View style={styles.container}>
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#ff4757" />
            <Text style={styles.loadingText}>Đang tải...</Text>
          </View>
        </View>
      </SafeAreaView>
    );
  }

  if (cameraPermission && !cameraPermission.granted) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <StatusBar style="light" />
        <View style={styles.container}>
          <View style={styles.permissionContainer}>
            <Text style={styles.permissionText}>Ứng dụng cần quyền truy cập camera để tiếp tục.</Text>
            <TouchableOpacity style={styles.permissionButton} onPress={() => requestCameraPermission()}>
              <Text style={styles.permissionButtonText}>Cấp quyền</Text>
            </TouchableOpacity>
          </View>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar style="light" />
      <View style={styles.container}>
        {errorMessage ? (
          <View style={styles.errorBanner}>
            <Text style={styles.errorText}>{errorMessage}</Text>
            <TouchableOpacity onPress={() => setErrorMessage(null)}>
              <Text style={styles.errorDismiss}>Đóng</Text>
            </TouchableOpacity>
          </View>
        ) : null}
        <View style={styles.tabBar}>
          <TouchableOpacity
            style={[styles.tabButton, activeTab === 'camera' && styles.tabButtonActive]}
            onPress={() => setActiveTab('camera')}
          >
            <Text style={styles.tabText}>Camera</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.tabButton, activeTab === 'gallery' && styles.tabButtonActive]}
            onPress={() => setActiveTab('gallery')}
          >
            <Text style={styles.tabText}>Gallery</Text>
          </TouchableOpacity>
        </View>
        <View style={styles.content}>{activeTab === 'camera' ? renderCameraSection() : renderGallerySection()}</View>
      </View>

      <Modal transparent visible={modalVisible} animationType="fade" onRequestClose={() => void closeModal(!isEditing)}>
        <View style={styles.modalBackdrop}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>{isEditing ? 'Chỉnh sửa ghi chú' : 'Thêm ghi chú'}</Text>
            <TextInput
              style={styles.captionInput}
              value={captionInput}
              onChangeText={setCaptionInput}
              placeholder="Nhập mô tả cho ảnh"
              placeholderTextColor="#666"
              multiline
            />
            <View style={styles.modalActions}>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonSecondary]}
                onPress={() => void closeModal(!isEditing)}
              >
                <Text style={styles.modalButtonText}>Hủy</Text>
              </TouchableOpacity>
              <TouchableOpacity style={[styles.modalButton, styles.modalButtonPrimary]} onPress={saveNote}>
                <Text style={styles.modalButtonText}>Lưu</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#0f0f0f',
  },
  container: {
    flex: 1,
    paddingHorizontal: 16,
    paddingBottom: 16,
    backgroundColor: '#0f0f0f',
  },
  content: {
    flex: 1,
  },
  tabBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 8,
    marginBottom: 16,
    backgroundColor: '#1b1b1b',
    borderRadius: 12,
    padding: 4,
  },
  tabButton: {
    flex: 1,
    paddingVertical: 10,
    alignItems: 'center',
    borderRadius: 10,
  },
  tabButtonActive: {
    backgroundColor: '#2c2c2c',
  },
  tabText: {
    color: '#f2f2f2',
    fontWeight: '600',
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  cameraContainer: {
    flex: 1,
    justifyContent: 'space-between',
    position: 'relative',
  },
  camera: {
    flex: 1,
    borderRadius: 16,
    overflow: 'hidden',
  },
  cameraOverlay: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    justifyContent: 'flex-end',
    alignItems: 'flex-end',
    padding: 16,
    backgroundColor: 'rgba(0, 0, 0, 0)',
  },
  flipButton: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    paddingVertical: 10,
    paddingHorizontal: 18,
    borderRadius: 999,
  },
  captureButton: {
    marginTop: 16,
    backgroundColor: '#ff4757',
    paddingVertical: 16,
    borderRadius: 999,
    alignItems: 'center',
  },
  buttonText: {
    color: '#ffffff',
    fontWeight: '700',
    letterSpacing: 1,
  },
  permissionContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
  },
  permissionText: {
    color: '#f2f2f2',
    fontSize: 16,
    textAlign: 'center',
    marginTop: 12,
  },
  permissionButton: {
    marginTop: 16,
    backgroundColor: '#ff4757',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 999,
  },
  permissionButtonText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  galleryContainer: {
    flex: 1,
    borderRadius: 16,
    backgroundColor: '#121212',
    padding: 12,
  },
  noteCard: {
    backgroundColor: '#1b1b1b',
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
  },
  photoWrapper: {
    width: '100%',
    height: 200,
    borderRadius: 12,
    overflow: 'hidden',
    backgroundColor: '#1e1e1e',
    marginBottom: 12,
  },
  photo: {
    width: '100%',
    height: '100%',
  },
  captionText: {
    color: '#f2f2f2',
    fontSize: 14,
    marginBottom: 12,
  },
  noteActions: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  noteActionButton: {
    backgroundColor: '#2c2c2c',
    borderRadius: 999,
    paddingVertical: 8,
    paddingHorizontal: 14,
    marginRight: 8,
    marginBottom: 8,
  },
  noteActionText: {
    color: '#ffffff',
    fontWeight: '600',
    fontSize: 12,
    letterSpacing: 0.5,
  },
  emptyGallery: {
    flexGrow: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyText: {
    color: '#8c8c8c',
    fontSize: 16,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 24,
  },
  loadingText: {
    color: '#f2f2f2',
    fontSize: 16,
    marginTop: 12,
  },
  errorBanner: {
    backgroundColor: '#3b1a1a',
    borderRadius: 12,
    paddingVertical: 10,
    paddingHorizontal: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 8,
  },
  errorText: {
    color: '#ffb4b4',
    flex: 1,
    marginRight: 12,
  },
  errorDismiss: {
    color: '#ffd7d7',
    fontWeight: '600',
  },
  modalBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
  },
  modalContent: {
    width: '100%',
    backgroundColor: '#1b1b1b',
    borderRadius: 16,
    padding: 24,
  },
  modalTitle: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 16,
  },
  captionInput: {
    minHeight: 80,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#2c2c2c',
    padding: 12,
    color: '#f2f2f2',
    textAlignVertical: 'top',
    marginBottom: 24,
  },
  modalActions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  modalButton: {
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 999,
  },
  modalButtonSecondary: {
    backgroundColor: '#2c2c2c',
  },
  modalButtonPrimary: {
    backgroundColor: '#ff4757',
    marginLeft: 12,
  },
  modalButtonText: {
    color: '#ffffff',
    fontWeight: '600',
    letterSpacing: 0.5,
  },
});

export default CameraNotesScreen;
