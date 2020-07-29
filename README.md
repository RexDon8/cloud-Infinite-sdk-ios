# cloud-Infinite-sdk-ios
## 开发准备

### SDK源码以及demo 获取

SDK以及demo 的下载地址：[iOS SDK及demo](https://github.com/tencentyun/cloud-Infinite-sdk-ios.git)

### SDK 介绍
数据万象 是腾讯云为客户提供的专业一体化的图片解决方案，涵盖图片上传、下载、存储、处理、识别等功能，目前数据万象提供图片缩放、裁剪、水印、转码、内容审核等多种功能，提供高效准确的图像识别及处理服务，减少人力投入，真正地实现人工智能；[了解更多](https://cloud.tencent.com/document/product/460/36540)。

TPG 是腾讯推出的自研图片格式，可将 JPG、PNG、GIF、WEBP 等格式图片转换为 TPG 格式，大幅减小图片大小。从而减小图片体积，快速加载图片，节省流量；[了解更多](https://cloud.tencent.com/document/product/460/43680)

CloudInfinite SDK 为开发者更加快速方便的使用数据万象功能，该sdk共包含4个子模块，分别是：

序号|模块|功能
--:|:--:|:--
1|CloudInfinite(默认模块)|根据用户对图片所需要的操作进行构建 CIImageLoadRequest 实例，CIImageLoadRequest主要包含url和header；该实例，可用于Loader；也可以用于SDWebImage-TPG；
2|Loader |使用CIImageLoadRequest实例，请求网络图片并返回图片data数据；
3|TPG|解码TPG格式图片并显示；即可用于显示普通图片，也可用于TPG图；
4|SDWebImage-TPG|自定义解码器，支持SDWebImage解码并显示TPG格式图片；

### SDK 导入
使用cocoapods的方式来进行导入。
根据实际项目需求在Podfile文件中添加所需要的模块：

~~~
 pod 'CloudInfinite',				#集成CloudInfinite模块
 pod 'CloudInfinite/TPG',			#集成TPG模块       
 pod 'CloudInfinite/Loader', 			#集成Loader模块  
 pod 'CloudInfinite/SDWebImage-TPG', 		#集成SDWebImage-TPG模块

~~~
然后在终端执行命令
~~~
 pod install 
~~~

## 状态

目前已经支持TPG图片下载以及解码显示功能，其余功能正在快速的迭代中；

## 使用
CloudInfinite iOS SDK提供四种加载图片的方式,下面将逐个介绍每一种加载方式的用法以及所需要集成的模块；

### 方式一 使用SDWebimage-TPG加载数据万象普通图片（推荐）
#### 集成 CloudInfinite ，SDWebImage-TPG模块；在CloudInfinite模块中构建出拥有万象数据图片基础功能的链接，使用SDWebImage自带的加载方法加载图片，示例代码：
    // 实例化CloudImage，用来构建请求图片请求连接；
    CloudImage * cloudImage = [CloudImage new];
    // 根据用户所选万象基础功能options 封装成一个CITransformation实例；
    CITransformation * transform = [[CITransformation alloc] initWithFormat:CIImageTypeJPG options:CILoadTypeUrlFooter];
    // 构建图片CIImageLoadRequest
    [cloudImage requestWithBaseUrl:[NSURL URLWithString:@"图片链接"] transform:tpgtransform request:^(CIImageLoadRequest * _Nonnull request) {

        //request 构建成功的CIImageLoadRequest实例，包含请求连接以及请求头，直接使用SDWebImage自带方法加载图片，如果需要设置请求头，则参考方式二
          [imageView sd_setImageWithURL:request.url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }];


### 方式二 使用SDWebimage-TPG加载TPG格式图片（推荐）
#### 集成 CloudInfinite，SDWebImage-TPG，TPG；在CloudInfinite模块中构建出请求TPG格式图片的链接，并且自定义下载器，使用SDWebImage自带的加载方法加载图片，示例代码：

    // 实例化CloudImage，用来构建请求图片请求连接；
    CloudImage * cloudImage = [CloudImage new];
    // 在option中指定请求TPG参数的方式；默认为CILoadTypeAcceptHeader 带 accpet 头部 accpet:image/TPG,如果指定为CILoadTypeUrlFooter则传参方式为在 url 后面中拼接 imageMogr2/format/ ***
    CITransformation * transform = [[CITransformation alloc] initWithFormat:CIImageTypeTPG options:CILoadTypeUrlFooter];
    // 构建图片CIImageLoadRequest
    [cloudImage requestWithBaseUrl:imageUrl transform:tpgtransform request:^(CIImageLoadRequest * _Nonnull request) {
        // request 构建成功的CIImageLoadRequest实例，包含请求连接以及请求头，在加载TPG格式图片时需要使用自定义的TPGWebImageDownloader 如果header固定不变 则使用单例的方式
        // self.downLoader = [TPGWebImageDownloader shareLoader];
        // [self.downLoader setHttpHeaderField:request.header];
        
        // 如果每次header不同，则使用该构造方式；
        self.downLoader = [[TPGWebImageDownloader alloc] initWithHeader:request.header];

        // 在context 中设置自定义ImageDownloader
        [self.tpgImageView sd_setImageWithURL:request.url placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageRefreshCached context:@{SDWebImageContextImageLoader:self.downLoader}];
    }];

### 方式三 使用自定义Loader模块加载普通图片（无缓存机制，推荐使用方式一）
#### 集成 CloudInfinite，Loader；在CloudInfinite模块中构建出拥有万象数据图片基础功能的链接，使用Loader模块的CIImageLoader进行加载图片，示例代码：

    // 实例化CloudImage，用来构建请求图片请求连接；
    CloudImage * cloudImage = [CloudImage new];
    // 根据用户所选万象基础功能options 进行构建CIImageLoadRequest；
    CITransformation * transform = [[CITransformation alloc] initWithFormat:CIImageTypeJPG options:CILoadTypeUrlFooter];
    // 构建图片CIImageLoadRequest
    [cloudImage requestWithBaseUrl:[NSURL URLWithString:@"图片链接"] transform:tpgtransform request:^(CIImageLoadRequest * _Nonnull request) {

        // 根据构建号的CIImageLoadRequest 实例，使用 Loader模块CIImageLoader类加载图片并且需要传入imageView控件
        [[CIImageLoader shareLoader] display:self.imageView loadRequest:request placeHolder:[UIImage imageNamed:@"placeholder"] loadComplete:^(NSData * _Nullable data, NSError * _Nullable error) {
            // 图片请求并显示完成返回图片data数据，如果加载失败返回错误信息
        }];

    }];


### 方式四 使用自定义Loader模块TPG格式图片（无缓存机制，推荐使用方式二）
#### 集成 CloudInfinite，Loader，TPG；在CloudInfinite模块中构建出请求TPG格式图片的链接，使用Loader模块中CIImageLoader进行请求TPG二进制数据，请求成功后使用TPG模块TPGImageView尽心解码以及显示TPG图片，示例代码：


    // 实例化CloudImage，用来构建请求图片请求连接；
    CloudImage * cloudImage = [CloudImage new];
    // 根据用户所选万象基础功能options 进行构建CIImageLoadRequest；
    CITransformation * transform = [[CITransformation alloc] initWithFormat:CIImageTypeJPG options:CILoadTypeUrlFooter];
    // 构建图片CIImageLoadRequest
    [cloudImage requestWithBaseUrl:[NSURL URLWithString:@"图片链接"] transform:tpgtransform request:^(CIImageLoadRequest * _Nonnull request) {

        // 根据构建号的CIImageLoadRequest 实例，使用 Loader模块CIImageLoader类请求TPG图片data数据，并且使用TPG模块的TPGImageView
        // 加载TPG data数据，TPGImageView 在内部自动解码；
		[[CIImageLoader shareLoader] loadData:request loadComplete:^(NSData * _Nullable data, NSError * _Nullable error) {
			[self.tpgImageView setTpgImageWithData:data loadComplete:^(NSData * _Nullable data, UIImage * _Nullable image, NSError * _Nullable error) {
                NSLog(@"%@",error);
 		    }];
            
        }];        

    }];

## 示例
#### 完整例子请参考CIImageLoaderDemo示例工程

### 使用过程中如果您遇到了问题或者有更好的建议欢迎提 issue以及pull request;