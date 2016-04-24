# FacebookLoginShare
Facebook for login and share demo

根据官方步骤配置信息以后，运行词项目即可使用

官方教程：

登录： - https://developers.facebook.com/docs/facebook-login

分享： - https://developers.facebook.com/docs/sharing

其他更详细参见：https://github.com/facebook/facebook-ios-sdk

# 可能遇到的问题
   AppDelegate.m

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

//如果发现弹出的登录无法关闭，请将添加下面这个，注释上面的代码

//解决方案来源：http://stackoverflow.com/questions/32299271/facebook-sdk-login-never-calls-back-my-application-on-ios-9

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                       annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}
