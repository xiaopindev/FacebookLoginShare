//
//  ViewController.m
//  FacebookLoginShareExample
//
//  Created by cdmac on 16/4/24.
//  Copyright © 2016年 chinadailyhk. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <UIImageView+WebCache.h>

@interface ViewController ()<FBSDKSharingDelegate>
{
    FBSDKLoginManager *_loginManager;
    NSString *_userID;
    NSString *_userName;
    NSString *_userHeadUrl;
}

@property (strong, nonatomic) UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIImageView *userHead;
@property (weak, nonatomic) IBOutlet UILabel *labID;
@property (weak, nonatomic) IBOutlet UILabel *labName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)customLogin:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions: @[@"public_profile"]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) {
                                    NSLog(@"Process error");
                                } else if (result.isCancelled) {
                                    NSLog(@"Cancelled");
                                } else {
                                    NSLog(@"Logged in");
                                    //获取用户id, 昵称，大头像
                                    if ([FBSDKAccessToken currentAccessToken]) {
                                        if (![[FBSDKAccessToken currentAccessToken].userID isEqualToString:_userID]) {
                                            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=id,name" parameters:nil];
                                            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                                NSLog(@"result\n%@",result);
                                                NSString *userID = result[@"id"];
                                                
                                                if (!error && [[FBSDKAccessToken currentAccessToken].userID isEqualToString:userID]) {
                                                    _userName = result[@"name"];
                                                    _userID = userID;
                                                    _userHeadUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",userID];
                                                    //具体参见：
                                                    //https://developers.facebook.com/docs/graph-api/reference/user/picture/
                                                    //type参数：small,normal,album,large,square
                                                }
                                            }];
                                        }
                                    }
                                    
                                }
                            }];
    
}

- (IBAction)getUserInfo:(id)sender {
    self.labID.text = _userID;
    self.labName.text = _userName;
    [self.userHead sd_setImageWithURL:[NSURL URLWithString:_userHeadUrl]];
}

- (IBAction)logout:(id)sender {
    [[[FBSDKLoginManager alloc] init] logOut];
}

- (IBAction)shareContent:(id)sender {
    NSString *shareTitle = @"This is a Title";
    NSString *shareText = @"This is a text";
    NSString *shareImageUrl = @"https://api.cdeclips.com/vdocms/videoImg/15330259017007413.jpg";
    NSString *shareLinkUrl = @"https://www.vdoenglish.com/video/videoView_videoView?video.id=1116";
    
    //4.35.0
    /*
     分享链接：contentURL
     应用说明：quote （可以放置标题）
     */
    
#if 0
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:shareLinkUrl];
    //引用说明
    content.quote = [NSString stringWithFormat:@"%@. Click the hyperlink below for details>>",shareTitle];
    //话题标签
    content.hashtag = [FBSDKHashtag hashtagWithString:@"#VDOEnglish"];
    //Facebook 应用
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:self];
#else
    //messenger 应用
    //判断messenger 是否安装的方式
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger-share-api://"]]) {
        //-canOpenURL: failed for URL: "fb-messenger-share-api:/" - error: "The operation couldn’t be completed. (OSStatus error -10814.)"
        
        FBSDKShareMessengerURLActionButton *detailButton = [[FBSDKShareMessengerURLActionButton alloc] init];
        detailButton.title = @"View Details";
        detailButton.url = [NSURL URLWithString:shareLinkUrl];
        
        FBSDKShareMessengerGenericTemplateElement *element = [[FBSDKShareMessengerGenericTemplateElement alloc] init];
        element.title = shareTitle;
        element.subtitle = shareText;
        element.imageURL = [NSURL URLWithString:shareImageUrl];
        element.button = detailButton;
        
        FBSDKShareMessengerGenericTemplateContent *content = [[FBSDKShareMessengerGenericTemplateContent alloc] init];
        content.pageID = shareLinkUrl;
        content.element = element;

        FBSDKMessageDialog *messageDialog = [[FBSDKMessageDialog alloc] init];
        messageDialog.shareContent = content;
        messageDialog.delegate = self;

        if ([messageDialog canShow]) {
            [messageDialog show];
        }
    }else{
        NSLog(@"没有安装messenger");
    }
    
#endif
}

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    NSLog(@"share OK\n%@",results);
    
    //如果存在postId,则说明成功
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    NSLog(@"share faild\n%@",error);
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    NSLog(@"share Cancel");
}

@end
