platform :ios ,'7.0'
pod 'AFNetworking'
pod 'THProgressView'
pod 'SDWebImage'
pod 'MWPhotoBrowser'
pod 'AMSmoothAlert'
pod 'BBBadgeBarButtonItem'
pod 'MCSwipeTableViewCell'
pod 'DZNEmptyDataSet'
pod 'MDCFocusView'
pod 'BlocksKit'
pod 'TNSexyImageUploadProgress'
pod 'JDFlipNumberView'
pod 'JGProgressHUD'
post_install do |installer|
    installer.project.targets.each do |target|
        target.build_configurations.each do |configuration|
            target.build_settings(configuration.name)['ARCHS'] = '$(ARCHS_STANDARD_32_BIT)'
        end
    end
end