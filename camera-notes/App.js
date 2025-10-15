import React, { useCallback, useEffect, useRef, useState } from 'react';
import {
  SafeAreaView,
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  FlatList,
  Image,
  Alert,
  ActivityIndicator,
  Modal,
  TextInput,
} from 'react-native';
import { Camera, CameraType } from 'expo-camera';
import * as FileSystem from 'expo-file-system';
import * as MediaLibrary from 'expo-media-library';
import * as Sharing from 'expo-sharing';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { StatusBar } from 'expo-status-bar';

const STORAGE_KEY = '@camera-notes/notes';

const App = () => {
  const cameraRef = useRef(null);
  const [activeTab, setActiveTab] = useState('camera');
  const [cameraType, setCameraType] = useState(CameraType.back);
  const [notes, setNotes] = useState([]);
  const [cameraPermission, requestCameraPermission] = Camera.useCameraPermissions();
  const [mediaPermission, requestMediaLibraryPermission] = MediaLibrary.usePermissions();
  const [isLoading, setIsLoading] = useState(true);
  const [isCaptionModalVisible, setIsCaptionModalVisible] = useState(false);
  const [pendingNote, setPendingNote] = useState(null);
  const [captionInput, setCaptionInput] = useState('');
  const [isEditingNote, setIsEditingNote] = useState(false);

  const loadNotes = useCallback(async () => {
    try {
      const stored = await AsyncStorage.getItem(STORAGE_KEY);
      if (stored) {
        setNotes(JSON.parse(stored));
      }
    } catch (error) {
      console.warn('Failed to load notes', error);
    }
  }, []);

  const persistNotes = useCallback(
    async (nextNotes) => {
      try {
        setNotes(nextNotes);
        await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(nextNotes));
      } catch (error) {
        console.warn('Failed to persist notes', error);
      }
    },
    [setNotes],
  );

  const takePhoto = useCallback(async () => {
    if (!cameraRef.current) {
      return null;
    }

    const photo = await cameraRef.current.takePictureAsync({ quality: 0.8, skipProcessing: true });
    const timestamp = Date.now();
    const fileName = `note_${timestamp}.jpg`;
    const destination = `${FileSystem.documentDirectory}${fileName}`;

    await FileSystem.copyAsync({
      from: photo.uri,
      to: destination,
    });

    let savedToLibraryUri = null;
    if (mediaPermission?.granted) {
      try {
        const asset = await MediaLibrary.createAssetAsync(destination);
        savedToLibraryUri = asset?.uri ?? null;
      } catch (error) {
        console.warn('Failed to save to media library', error);
      }
    }

    return { id: fileName, uri: destination, savedToLibraryUri };
  }, [mediaPermission]);

  const handleCapturePhoto = useCallback(async () => {
    try {
      const nextNoteDraft = await takePhoto();
      if (!nextNoteDraft) {
        return;
      }

      setPendingNote({ ...nextNoteDraft, caption: '' });
      setCaptionInput('');
      setIsEditingNote(false);
      setIsCaptionModalVisible(true);
    } catch (error) {
      console.warn('Failed to capture photo', error);
      Alert.alert('Lỗi', 'Không thể chụp ảnh. Vui lòng thử lại.');
    }
  }, [takePhoto]);

  const toggleCameraType = useCallback(() => {
    setCameraType((current) => (current === CameraType.back ? CameraType.front : CameraType.back));
  }, []);

  const saveNewNote = useCallback(async () => {
    if (!pendingNote) {
      return;
    }

    const caption = captionInput.trim();
    const noteToSave = { ...pendingNote, caption };

    try {
      const nextNotes = [noteToSave, ...notes];
      await persistNotes(nextNotes);
      setPendingNote(null);
      setCaptionInput('');
      setIsEditingNote(false);
      setIsCaptionModalVisible(false);
      setActiveTab('gallery');
    } catch (error) {
      console.warn('Failed to save note', error);
      Alert.alert('Lỗi', 'Không thể lưu ghi chú. Vui lòng thử lại.');
    }
  }, [captionInput, notes, pendingNote, persistNotes]);

  const applyEdit = useCallback(async () => {
    if (!pendingNote) {
      return;
    }

    const caption = captionInput.trim();
    const updatedNotes = notes.map((note) => (note.id === pendingNote.id ? { ...note, caption } : note));

    try {
      await persistNotes(updatedNotes);
      setPendingNote(null);
      setCaptionInput('');
      setIsEditingNote(false);
      setIsCaptionModalVisible(false);
    } catch (error) {
      console.warn('Failed to update note', error);
      Alert.alert('Lỗi', 'Không thể cập nhật ghi chú. Vui lòng thử lại.');
    }
  }, [captionInput, notes, pendingNote, persistNotes]);

  const editNote = useCallback((note) => {
    setPendingNote(note);
    setCaptionInput(note.caption ?? '');
    setIsEditingNote(true);
    setIsCaptionModalVisible(true);
  }, []);

  const saveToLibrary = useCallback(
    async (note) => {
      try {
        let permission = mediaPermission;
        if (!permission?.granted) {
          permission = await requestMediaLibraryPermission();
        }

        if (!permission?.granted) {
          Alert.alert('Quyền truy cập', 'Không thể lưu vì thiếu quyền truy cập thư viện.');
          return;
        }

        const asset = await MediaLibrary.createAssetAsync(note.uri);
        const updatedNotes = notes.map((item) =>
          item.id === note.id ? { ...item, savedToLibraryUri: asset?.uri ?? item.savedToLibraryUri ?? null } : item,
        );
        await persistNotes(updatedNotes);
        Alert.alert('Thành công', 'Ảnh đã được lưu vào thư viện.');
      } catch (error) {
        console.warn('Failed to save to library', error);
        Alert.alert('Lỗi', 'Không thể lưu ảnh vào thư viện.');
      }
    },
    [mediaPermission, notes, persistNotes, requestMediaLibraryPermission],
  );

  const shareNote = useCallback(async (note) => {
    try {
      const available = await Sharing.isAvailableAsync();
      if (!available) {
        Alert.alert('Chia sẻ', 'Chức năng chia sẻ không khả dụng trên thiết bị này.');
        return;
      }
      await Sharing.shareAsync(note.uri);
    } catch (error) {
      console.warn('Failed to share note', error);
      Alert.alert('Lỗi', 'Không thể chia sẻ ảnh.');
    }
  }, []);

  const deleteNote = useCallback(
    (note) => {
      Alert.alert('Xoá ảnh', 'Bạn có chắc muốn xoá ảnh này?', [
        { text: 'Hủy', style: 'cancel' },
        {
          text: 'Xoá',
          style: 'destructive',
          onPress: async () => {
            const filteredNotes = notes.filter((item) => item.id !== note.id);
            try {
              await persistNotes(filteredNotes);
              if (note.uri) {
                await FileSystem.deleteAsync(note.uri, { idempotent: true });
              }
            } catch (error) {
              console.warn('Failed to delete note', error);
              Alert.alert('Lỗi', 'Không thể xoá ảnh. Vui lòng thử lại.');
            }
          },
        },
      ]);
    },
    [notes, persistNotes],
  );

  const handleCancelNote = useCallback(async () => {
    if (!isEditingNote && pendingNote?.uri) {
      try {
        await FileSystem.deleteAsync(pendingNote.uri, { idempotent: true });
      } catch (error) {
        console.warn('Failed to delete temp note file', error);
      }
    }
    setPendingNote(null);
    setCaptionInput('');
    setIsEditingNote(false);
    setIsCaptionModalVisible(false);
  }, [isEditingNote, pendingNote]);

  useEffect(() => {
    const initAsync = async () => {
      await Promise.allSettled([requestCameraPermission(), requestMediaLibraryPermission(), loadNotes()]);
      setIsLoading(false);
    };

    initAsync();
  }, [loadNotes, requestCameraPermission, requestMediaLibraryPermission]);

  const renderCameraView = () => {
    if (cameraPermission && cameraPermission.status === 'denied') {
      return (
        <View style={styles.permissionContainer}>
          <Text style={styles.permissionText}>Ứng dụng cần quyền truy cập camera.</Text>
        </View>
      );
    }

    return (
      <View style={styles.cameraContainer}>
        <Camera ref={cameraRef} style={styles.camera} type={cameraType}>
          <View style={styles.cameraOverlay}>
            <TouchableOpacity style={styles.flipButton} onPress={toggleCameraType}>
              <Text style={styles.buttonText}>Flip</Text>
            </TouchableOpacity>
          </View>
        </Camera>
        <TouchableOpacity style={styles.captureButton} onPress={handleCapturePhoto}>
          <Text style={styles.buttonText}>Chụp</Text>
        </TouchableOpacity>
      </View>
    );
  };

  const renderGallery = () => (
    <View style={styles.galleryContainer}>
      <FlatList
        data={notes}
        numColumns={1}
        keyExtractor={(item) => item.id}
        contentContainerStyle={notes.length === 0 ? styles.emptyGallery : undefined}
        ListEmptyComponent={<Text style={styles.emptyText}>Chưa có ảnh nào</Text>}
        renderItem={({ item }) => (
          <View style={styles.noteCard}>
            <TouchableOpacity style={styles.photoWrapper} onPress={() => shareNote(item)}>
              <Image source={{ uri: item.uri }} style={styles.photo} />
            </TouchableOpacity>
            <Text style={styles.captionText}>{item.caption ? item.caption : 'Chưa có ghi chú'}</Text>
            <View style={styles.noteActions}>
              <TouchableOpacity style={styles.noteActionButton} onPress={() => editNote(item)}>
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
        )}
      />
    </View>
  );

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar style="light" />
      <View style={styles.container}>
        {isLoading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#ff4757" />
            <Text style={styles.loadingText}>Đang tải...</Text>
          </View>
        ) : (
          <>
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
            <View style={styles.content}>{activeTab === 'camera' ? renderCameraView() : renderGallery()}</View>
          </>
        )}
      </View>
      <Modal transparent visible={isCaptionModalVisible} animationType="fade" onRequestClose={handleCancelNote}>
        <View style={styles.modalBackdrop}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>{isEditingNote ? 'Chỉnh sửa ghi chú' : 'Thêm ghi chú'}</Text>
            <TextInput
              style={styles.captionInput}
              value={captionInput}
              onChangeText={setCaptionInput}
              placeholder="Nhập mô tả cho ảnh"
              placeholderTextColor="#666"
              multiline
            />
            <View style={styles.modalActions}>
              <TouchableOpacity style={[styles.modalButton, styles.modalButtonSecondary]} onPress={handleCancelNote}>
                <Text style={styles.modalButtonText}>Hủy</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonPrimary]}
                onPress={isEditingNote ? applyEdit : saveNewNote}
              >
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
  content: {
    flex: 1,
  },
  cameraContainer: {
    flex: 1,
    justifyContent: 'space-between',
  },
  camera: {
    flex: 1,
    borderRadius: 16,
    overflow: 'hidden',
  },
  cameraOverlay: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'flex-end',
    padding: 16,
    backgroundColor: 'rgba(0, 0, 0, 0.25)',
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
  },
  permissionText: {
    color: '#f2f2f2',
    fontSize: 16,
    textAlign: 'center',
    paddingHorizontal: 24,
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
  emptyGallery: {
    flexGrow: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyText: {
    color: '#8c8c8c',
    fontSize: 16,
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
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 24,
  },
  loadingText: {
    color: '#f2f2f2',
    fontSize: 16,
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

export default App;
