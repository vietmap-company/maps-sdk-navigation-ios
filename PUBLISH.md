### Note: VietMapNavigation sẽ phụ thuộc vào VietMapCoreNavigation, nên khi VietMapCoreNavigation có thay đổi thì phải build lại VietMapNavigation

### Cập nhật `VietMapCoreNavigation` và `VietMapNavigation` độc lập do `Cocoapod` cần khoảng 15p thì bản mới mới lên, không thể chạy CICD update cùng lúc cho 2 lib

## 1. Release VietMapCoreNavigation
Thay đổi version trong file `VietMapCoreNavigation.podspec`

- Tạo tag mới có định dạng `'vm-navigation-core-v[0-9]+.[0-9]+.[0-9]+'`
ví dụ: `vm-navigation-core-v2.1.6`
Trong đó:
    - `vm-navigation-core-v` là định dạng để Github action nhận dạng đang có request yêu cầu tạo bản release mới
    - `2.1.6` là version được khai báo tại `s.version = "2.1.6"` trong file `VietMapCoreNavigation.podspec`
- Commit và push code mới tạo lên tag mới tạo. 
- Theo dõi quá trình chạy tại [đây](https://github.com/vietmap-company/maps-sdk-navigation-ios/actions)

### Terminal
- Tạo tag mới
```bash
git tag vm-navigation-core-v
```
- Add & commit code
- Push code lên tag mới
```bash
git push origin vm-navigation-core-v
```

## 2. Release VietMapNavigation
Thay đổi version trong file `VietMapNavigation.podspec`

- Tạo tag mới có định dạng `'vm-navigation-v[0-9]+.[0-9]+.[0-9]+'`
ví dụ: `vm-navigation-v2.1.6`
Trong đó:
    - `vm-navigation-v` là định dạng để Github action nhận dạng đang có request yêu cầu tạo bản release mới
    - `2.1.6` là version được khai báo tại `s.version = "2.1.6"` trong file `VietMapNavigation.podspec`
- Commit và push code mới tạo lên tag mới tạo. 
- Theo dõi quá trình chạy tại [đây](https://github.com/vietmap-company/maps-sdk-navigation-ios/actions)

### Terminal
- Tạo tag mới
```bash
git tag vm-navigation-v
```
- Add & commit code
- Push code lên tag mới
```bash
git push origin vm-navigation-v
```
### Lưu ý:
- Mỗi định dạng tag sẽ chỉ chạy & release duy nhất 1 lib, không thể chạy đồng thời.
- Nếu có cập nhật ở cả 2 lib, đẩy lib `VietMapCoreNavigation` lên trước và chờ đến khi `Cocoapod` hoàn thành mới đẩy tiếp lib `VietMapNavigation`.


# Cấu hình github action key
https://github.com/vietmap-company/maps-sdk-navigation-ios/settings/secrets/actions

## Tài liệu tham khảo:
### Link parse medium premium =))
http://webcache.googleusercontent.com/search?q=cache:https://medium.com/swlh/automated-cocoapod-releases-with-github-actions-8526dd4535c7&strip=0&vwsrc=1&referer=medium-parser
### Link gốc
https://medium.com/swlh/automated-cocoapod-releases-with-github-actions-8526dd4535c7
# ----------------------------------------------------
# Tài liệu dưới đây sử dụng để release bằng tay qua cocoapods

# Thực hiện build
Thay đổi version trong file VietMapNavigation.podspec
push lên repo + tag github (tag là version thay đổi)

ví dụ :   s.version = "2.1.6" thì tag là 2.1.6
# Validate xcframework
```bash
pod spec lint VietMapNavigation.podspec --allow-warnings
```

# Push lên cocoapods
```bash
pod trunk push VietMapNavigation.podspec --allow-warnings
```

Note replace VietMapNavigation.podspec with your podspec file name