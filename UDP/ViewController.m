//
//  ViewController.m
//  UDP
//
//  Created by zhangfei on 15/8/18.
//  Copyright (c) 2015年 zhangfei. All rights reserved.
//
/*
 使用方法：
 1、获取GDataXMLNode.h/m文件，将GDataXMLNode.h/m文件添加到工程中
 2、向工程中增加“libxml2.dylib”库
 3、在工程的“Build Settings”页中找到“Header Search Path”项，添加/usr/include/libxml2"到路径中
 4、添加“GDataXMLNode.h”文件到头文件中，如工程能编译通过，则说明GDataXMLNode添加成功
 */

#import "ViewController.h"
#import "AsyncUdpSocket.h"
#import "GDataXMLNode.h"

@interface ViewController ()<AsyncUdpSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *ipField;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) AsyncUdpSocket *sendSocket;
@property (nonatomic, strong) AsyncUdpSocket *reciveSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _reciveSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [_reciveSocket bindToPort:6789 error:nil];
    
    [_reciveSocket receiveWithTimeout:-1 tag:0];
    
    _sendSocket = [[AsyncUdpSocket alloc]initWithDelegate:self];
    [_sendSocket bindToPort:6788 error:nil];
}
/**
 *  接受到消息HOST发送端ip
 *
 */
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    
    /*
     <message>
     <name>
     <text>
     */
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *messageEle = [doc rootElement];
    GDataXMLElement *nameEle = [[messageEle elementsForName:@"name"] lastObject];
    GDataXMLElement *textEle = [[messageEle elementsForName:@"text"] lastObject];
    
    _textView.text = [NSString stringWithFormat:@"%@%@:%@\n", _textView.text, nameEle.stringValue, textEle.stringValue];
    
    //继续监听接收消息
    [_reciveSocket receiveWithTimeout:-1 tag:0];
    return YES;
}

- (IBAction)sendText:(id)sender {
    
    GDataXMLElement *nameEle = [GDataXMLElement elementWithName:@"name" stringValue:@"zhangferry"];
    GDataXMLElement *textEle = [GDataXMLElement elementWithName:@"text" stringValue:_textField.text];
    GDataXMLElement *messageEle = [GDataXMLElement elementWithName:@"message"];
    [messageEle addChild:nameEle];
    [messageEle addChild:textEle];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithRootElement:messageEle];
    //发送
    [_sendSocket sendData:doc.XMLData toHost:_ipField.text port:6789 withTimeout:30 tag:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
