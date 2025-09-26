import { useEffect, useState } from "react";
import { Device } from "@capacitor/device";
import { App as CapApp } from "@capacitor/app";
import { Network } from "@capacitor/network";
import { Share } from "@capacitor/share";

export default function App() {
  const [deviceInfo, setDeviceInfo] = useState<any>(null);
  const [appInfo, setAppInfo] = useState<any>(null);
  const [network, setNetwork] = useState<any>(null);
  const [sessionId] = useState(() => Math.random().toString(36).substring(2, 10));
  const [shareMessage, setShareMessage] = useState<string>("");

  // Load info khi app start
  useEffect(() => {
    (async () => {
      setDeviceInfo(await Device.getInfo());
      setAppInfo(await CapApp.getInfo().catch(() => null));
      setNetwork(await Network.getStatus());
    })();

    // Lắng nghe realtime khi đổi mạng
    const listener = Network.addListener("networkStatusChange", (status) => {
      setNetwork(status);
    });

    return () => {
      listener.then((h) => h.remove());
    };
  }, []);

  // Chuẩn bị dữ liệu để share
  useEffect(() => {
    let summary = `📱 Device Dashboard\n\n`;
    summary += `Session ID: ${sessionId}\n\n`;
    if (network) {
      summary += `🌐 Network: ${network.connected ? "Connected" : "Disconnected"} (${network.connectionType})\n`;
    }
    if (appInfo) {
      summary += `📦 App: ${appInfo.name} v${appInfo.version}\n`;
    }
    if (deviceInfo) {
      summary += `🖥️ Device: ${deviceInfo.model} (${deviceInfo.platform}, ${deviceInfo.osVersion})\n`;
      summary += `Maker: ${deviceInfo.manufacturer}\n`;
    }
    setShareMessage(summary);
  }, [network, appInfo, deviceInfo, sessionId]);

  // Hàm chia sẻ
  const handleShare = async () => {
    try {
      await Share.share({
        title: "Device Dashboard Info",
        text: shareMessage,
        dialogTitle: "Chia sẻ thông tin thiết bị",
      });
    } catch (err) {
      console.warn("❌ Share not supported on this platform", err);

      // fallback copy to clipboard
      await navigator.clipboard.writeText(shareMessage);
      alert("📋 Thông tin đã được copy vào clipboard!");
    }
  };

  return (
    <div className="min-h-screen bg-gray-900 text-white p-6 space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <h1 className="text-4xl font-bold text-center flex-1">📱 Device Dashboard</h1>
        <button
          onClick={handleShare}
          className="ml-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded shadow text-white"
        >
          Share
        </button>
      </div>

      {/* Session */}
      <section className="bg-gray-800 rounded-lg p-4 shadow">
        <h2 className="text-xl font-semibold mb-2">Session</h2>
        <p>Session ID: <span className="text-green-400">{sessionId}</span></p>
      </section>

      {/* Network */}
      <section className="bg-gray-800 rounded-lg p-4 shadow">
        <h2 className="text-xl font-semibold mb-2">Network</h2>
        {network && (
          <>
            <p>Connected: {network.connected ? "✅" : "❌"}</p>
            <p>Type: {network.connectionType}</p>
          </>
        )}
      </section>

      {/* App */}
      <section className="bg-gray-800 rounded-lg p-4 shadow">
        <h2 className="text-xl font-semibold mb-2">App</h2>
        {appInfo ? (
          <>
            <p>Name: {appInfo.name}</p>
            <p>Version: {appInfo.version}</p>
          </>
        ) : (
          <p className="text-gray-400">⚠️ Not available on Web preview</p>
        )}
      </section>

      {/* Device */}
      <section className="bg-gray-800 rounded-lg p-4 shadow">
        <h2 className="text-xl font-semibold mb-2">Device</h2>
        {deviceInfo && (
          <>
            <p>Model: {deviceInfo.model}</p>
            <p>Platform: {deviceInfo.platform}</p>
            <p>OS: {deviceInfo.osVersion}</p>
            <p>Manufacturer: {deviceInfo.manufacturer}</p>
            <p>UUID: {deviceInfo.uuid ?? "Not available on web"}</p>
          </>
        )}
      </section>

      {/* Spec của bài tập */}
      <section className="bg-gray-800 rounded-lg p-6 shadow mt-8">
        <h2 className="text-2xl font-bold mb-4">📋 Bài tập Capacitor – Cross-platform Apps</h2>
        
        <p className="mb-2"><strong>Mục tiêu:</strong> Hiển thị thông tin thiết bị & ứng dụng.</p>
        <p className="mb-2"><strong>Plugin:</strong> <code>@capacitor/device</code>, <code>@capacitor/network</code>, <code>@capacitor/app</code>, <code>@capacitor/share</code></p>

        <div className="mt-4">
          <h3 className="font-semibold mb-1">Yêu cầu tối thiểu:</h3>
          <ul className="list-disc ml-6 space-y-1 text-gray-300">
            <li>Model, OS, phiên bản app</li>
            <li>Trạng thái mạng hiện tại</li>
            <li>Sinh ID ngẫu nhiên cho phiên</li>
          </ul>
        </div>

        <div className="mt-4">
          <h3 className="font-semibold mb-1">Mở rộng:</h3>
          <ul className="list-disc ml-6 space-y-1 text-gray-300">
            <li>Cập nhật realtime khi đổi mạng</li>
            <li>Chia sẻ thông tin bằng Share</li>
          </ul>
        </div>
      </section>
    </div>
  );
}
