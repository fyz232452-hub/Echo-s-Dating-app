import Foundation
import CoreLocation
import LocalAuthentication
import Combine

// MARK: - 定位服务：只取一次当前地点名称，不持续追踪
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var statusText: String = ""
    @Published var isLoading = false

    private let manager = CLLocationManager()
    private var completion: ((String) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    /// 请求获取当前地点名称，结果通过 completion 回调
    func requestPlaceName(completion: @escaping (String) -> Void) {
        self.completion = completion
        isLoading = true
        statusText = "正在定位…"

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            isLoading = false
            statusText = "未授权定位，请手动输入"
            completion("")
        default:
            manager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else if status == .denied || status == .restricted {
            isLoading = false
            statusText = "未授权定位，请手动输入"
            completion?("")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(loc) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                if error != nil || placemarks?.isEmpty != false {
                    self.statusText = "定位失败，请手动输入"
                    self.completion?("")
                    return
                }
                if let p = placemarks?.first {
                    // 拼接出尽量友好的地名
                    let parts = [p.name, p.locality, p.subLocality]
                        .compactMap { $0 }
                        .filter { !$0.isEmpty }
                    var name = parts.joined(separator: " ")
                    if name.isEmpty {
                        name = p.locality ?? p.administrativeArea ?? ""
                    }
                    self.statusText = name.isEmpty ? "未能识别地点" : "已定位"
                    self.completion?(name)
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.statusText = "定位失败，请手动输入"
            self.completion?("")
        }
    }
}

// MARK: - 面容 / 指纹解锁
enum BiometricAuth {
    /// 设备是否支持设备密码 / 生物识别
    static var isAvailable: Bool {
        let ctx = LAContext()
        var error: NSError?
        return ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    /// 验证身份（面容 / 指纹；设备无生物识别时回退到锁屏密码）
    static func authenticate(
        reason: String = "解锁以查看你的私密约会记录",
        completion: @escaping (Bool) -> Void
    ) {
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            // 无法使用系统解锁能力时直接放行，避免把用户锁在门外
            DispatchQueue.main.async { completion(true) }
            return
        }
        ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
            DispatchQueue.main.async { completion(success) }
        }
    }
}
