//
//  GuideController.m
//  MineTrip
//
//  Created by ChangWingchit on 2017/7/5.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "GuideController.h"
#import <AVFoundation/AVFoundation.h>
//#import "LoactionViewController.h"
#import "MBProgressHUD+NJ.h"
#import "UIBarButtonItem+MineShopBarButtonCustom.h"
#import "Config.h"
#import "UIView+Extension.h"

@interface GuideController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    int _num;
    BOOL _isUP;//判断扫描线向上还是向下运动
}

@property (nonatomic,strong) AVCaptureDevice *device;
@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preview;

@property (nonatomic,strong) UIImageView *line;//设置二维码扫描线
@property (nonatomic,strong) NSTimer *timer;//定时器
@property (nonatomic,strong) UIImageView *backView;//背景框

@end

@implementation GuideController

#pragma mark - Lazy Load
- (UIImageView*)backView
{
    return MY_LAZY(_backView, ({
        UIImageView *imageView  = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, 300)];
        imageView.image = [UIImage imageNamed:@"pick_bg"];
        imageView;
    }));
}

- (UIImageView*)line
{
    return MY_LAZY(_line, ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, self.backView.y+5, SCREEN_WIDTH-60, 2)];
        imageView.image = [UIImage imageNamed:@"line"];
        imageView;
    }));
}

- (NSTimer*)timer
{
    return MY_LAZY(_timer, ({
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                      target:self
                                                    selector:@selector(animation)
                                                    userInfo:nil
                                                     repeats:YES];
        timer;
    }));

}

#pragma mark - Life Cycle
- (void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self beginScan];//开始扫描
    [self setupSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PriVate Method
/**设置导航栏标题和按钮*/
- (void)setupNavigationBar
{
    self.title = @"电子导游";
    UIBarButtonItem *item = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemClicked) image:@"menu" selectImage:nil];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -5;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, item];
    
    UIBarButtonItem *rightItem = [UIBarButtonItem itemWithTarget:self action:@selector(rightBarBtnItemClicked) image:@"jingxuanfuwu" selectImage:nil];
    UIBarButtonItem *negativeSpacer2 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer2.width = 5;
    self.navigationItem.rightBarButtonItems = @[rightItem,negativeSpacer2];
}

/**导航栏左边按钮点击*/
//- (void)barButtonItemClicked
//{
//    if ([self mainViewController].isLeft) {
//        [[self mainViewController]hideLeftView];
//    }else{
//        [[self mainViewController]showLeftView];
//    }
//}

/**导航栏右边按钮点击*/
- (void)rightBarBtnItemClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**设置子视图*/
- (void)setupSubViews
{
    self.view.backgroundColor = [UIColor blackColor];
    
    //二维码扫描框背景
    [self.view addSubview:self.backView];
    
    //二维码扫描线
    [self.view addSubview:self.line];
    
    //提示文字
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(self.backView.x, self.backView.y+self.backView.height, self.backView.width,44)];
    lab.backgroundColor = [UIColor clearColor];
    lab.font = [UIFont systemFontOfSize:14];
    lab.numberOfLines = 2;
    lab.textColor = [UIColor whiteColor];
    lab.text = @"将二维码图像置于矩形方框内，离手机摄像头10CM左右，即可显示你当前位置。";
    [self.view addSubview:lab];
    
    //初始化动画参数
    _num = 0;
    _isUP = NO;
    
    //启动定时器，让扫描线上下浮动
    [self timer];
}

/*创建二维码扫描动画界面算法*/
- (void)animation
{
    if (_isUP == NO)
    {
        _num++;
        int tmpY = _num*2;
        self.line.frame = CGRectMake(30, self.backView.y+5+tmpY, SCREEN_WIDTH-60, 2);
        if (tmpY == 280)
        {
            _isUP = YES;
        }
    }
    else
    {
        _num--;
        int tmpY = _num*2;
        self.line.frame = CGRectMake(30, self.backView.y+5+tmpY, SCREEN_WIDTH-60, 2);
        if (_num == 0)
        {
            _isUP = NO;
        }
    }
}

/**开始扫描*/
- (void)beginScan
{
    // 创建捕获设备Device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 创建输入设备Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // 创建输出设备Output
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 创建会话Session
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];//设置会话质量(高清)
    if ([self.session canAddInput:self.input])//能否添加输入设备
    {
        [self.session addInput:self.input];//会话中添加输入设备
    }
    
    if ([self.session canAddOutput:self.output])//能否添加输出设备
    {
        [self.session addOutput:self.output];//会话中添加输出设备
    }
    
    // 设置条码类型 AVMetadataObjectTypeQRCode(二维码)
    self.output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // 创建捕获录像遮照层Preview
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;//等比填充
    self.preview.frame =CGRectMake(20,self.backView.y+10,SCREEN_WIDTH-40,280);
    [self.view.layer insertSublayer:self.preview atIndex:0];//当前视图插入遮照层Preview
    
    // 开始启动会话Start
    [_session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
//二维码扫描结果回调方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [_session stopRunning];// 停止当前会话Stop
    _session = nil;
    [_preview removeFromSuperlayer]; //把图层移除

    
    [self.timer invalidate];//停止定时器
    self.timer = nil;//释放定时器对象
    
    //获取扫描信息
    NSString *stringValue = nil;
    if ([metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;//获取扫描结果
    }
    
    //http://weixin.qq.com/r/ppwOFqLEg--8reZ198m0
    
    if ([stringValue hasPrefix:@"http"]) {
        [MBProgressHUD showTestMessage:@"请扫描官方地址二维码"];
        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:nil afterDelay:1];

    }else{
        NSArray *arr = [stringValue componentsSeparatedByString:@","];
        if (arr && [arr count]) {
            
            NSString *longitude = (NSString*)arr[0];
            NSString *latitude = (NSString*)arr[1];
            NSString *localtionName = (NSString*)arr[2];
            
//            LoactionViewController *vc = [LoactionViewController new];
//            vc.longitude = longitude;
//            vc.latitude = latitude;
//            vc.localtionName = localtionName;
//            [self.navigationController pushViewController:vc animated:YES];
            
        }else{
            [MBProgressHUD showTestMessage:@"请扫描官方地址二维码"];
        }
    }
    
}

@end
