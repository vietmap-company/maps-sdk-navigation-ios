Note: VietMapNavigation sẽ phụ thuộc vào VietMapCoreNavigation, nên khi VietMapCoreNavigation có thay đổi thì phải build lại VietMapNavigation





#-----------------------------------------------------------------------

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