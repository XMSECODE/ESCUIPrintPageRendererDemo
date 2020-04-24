//
//  ViewController.m
//  ESCUIPrintPageRendererDemo
//
//  Created by xiang on 2020/4/17.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()

@property(nonatomic,weak)WKWebView* webView;

@property(nonatomic,strong)UIDocumentInteractionController* documentInteractionController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebView *webView = [[WKWebView alloc] init];
    self.webView = webView;
    [self.view addSubview:self.webView];
    
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlRequest];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存为PDF文件" style:UIBarButtonItemStyleDone target:self action:@selector(didClickSaveButton)];
    
}

- (void)didClickSaveButton {
    //1、 生成报告
    NSString *pdfFilePath = [self createReprotPDFFile];
    if (pdfFilePath == nil) {
        NSLog(@"生成PDF报告文件失败");
        return;
    }
//    NSLog(@"pdfFilePath===%@",pdfFilePath);
    NSURL *fileURL = [NSURL fileURLWithPath:pdfFilePath];
    
    UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
//    documentInteractionController.delegate = self;
    BOOL openResult = [documentInteractionController presentOpenInMenuFromRect:self.navigationController.view.bounds inView:self.navigationController.view animated:YES];
    self.documentInteractionController = documentInteractionController;
    if (openResult == NO) {
        NSLog(@"分享文件失败");
    }
}


- (NSString *)createReprotPDFFile {
    
    UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
    
    [renderer addPrintFormatter:[self.webView viewPrintFormatter] startingAtPageAtIndex:0];
    
    CGRect page;
    page.origin.x = 0;
    page.origin.y = 0;
    page.size.width = self.webView.scrollView.contentSize.width;
    //预计算打印高度   （self.webView.scrollView.contentSize.height高度有问题，高度过高）
    page.size.height = [self getPrintHeight];
    
    CGRect printable = CGRectInset( page, 0, 0 );
    
    [renderer setValue:[NSValue valueWithCGRect:page] forKey:@"paperRect"];
    [renderer setValue:[NSValue valueWithCGRect:printable] forKey:@"printableRect"];
    
    NSMutableData * pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData( pdfData, page, nil );
    
//    NSLog(@"%@===",NSStringFromCGRect(page));
    for (NSInteger i=0; i < [renderer numberOfPages]; i++) {
        UIGraphicsBeginPDFPage();
        CGRect bounds = UIGraphicsGetPDFContextBounds();
        [renderer drawPageAtIndex:i inRect:bounds];
//        NSLog(@"%@===%d",NSStringFromCGRect(page),i);
    }
    
//    UIGraphicsBeginPDFPage();
//    [renderer drawPageAtIndex:0 inRect:page];
    
    UIGraphicsEndPDFContext();
    
    NSString *pdfPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES).lastObject;
    NSString *fileName = [NSString stringWithFormat:@"test.pdf"];
    pdfPath = [NSString stringWithFormat:@"%@/reportFile",pdfPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pdfPath] == NO) {
        NSError *error;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:pdfPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (result == NO) {
            return nil;
        }
    }
    pdfPath = [NSString stringWithFormat:@"%@/%@",pdfPath,fileName];
    
    BOOL result = [pdfData writeToFile:pdfPath atomically:YES];
    if (result == YES) {
        return pdfPath;
    }else {
        return nil;
    }
}


//预计算打印高度（）
- (CGFloat)getPrintHeight {
    
    UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
    
    [renderer addPrintFormatter:[self.webView viewPrintFormatter] startingAtPageAtIndex:0];
    
    CGRect page;
    page.origin.x = 0;
    page.origin.y = 0;
    page.size.width = self.webView.scrollView.contentSize.width;
    page.size.height = 50;

    CGRect printable = CGRectInset( page, 0, 0 );
    
    [renderer setValue:[NSValue valueWithCGRect:page] forKey:@"paperRect"];
    [renderer setValue:[NSValue valueWithCGRect:printable] forKey:@"printableRect"];
    
    NSMutableData * pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData( pdfData, page, nil );
    
    CGFloat height = 0;
    for (NSInteger i=0; i < [renderer numberOfPages]; i++) {
        UIGraphicsBeginPDFPage();
        CGRect bounds = UIGraphicsGetPDFContextBounds();
        [renderer drawPageAtIndex:i inRect:bounds];
        height += bounds.size.height;
    }
    
    UIGraphicsEndPDFContext();
    return height;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.webView.frame = self.view.bounds;
}


@end
