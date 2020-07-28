# cloud-Infinite-sdk-ios
## 开发准备

### SDK源码以及demo 获取

SDK以及demo 的下载地址：[iOS SDK](https://github.com/tencentyun/cloud-Infinite-sdk-ios.git)

### SDK 介绍
数据万象（Cloud Infinite，CI）是腾讯云为客户提供的专业一体化的图片解决方案，涵盖图片上传、下载、存储、处理、识别等功能，目前数据万象提供图片缩放、裁剪、水印、转码、内容审核等多种功能，提供高效准确的图像识别及处理服务，减少人力投入，真正地实现人工智能。
CloudInfinite SDK 是封装了数据万象基础功能的开发包，为企业项目中图片常用的操作，比如缩放，裁剪，水印等提供解决方案；
目前CloudInfinite SDK共包含4个子模块，分别是：
* CloudInfinite 主要功能：根据用户对图片所需要的处理功能构建 CIImageLoadRequest 实例，CIImageLoadRequest主要包含url和header；CIImageLoadRequest 实例，可用于CImageLoader；也可以用于SDWebImage-TPG；

* Loader 主要功能:使用CIImageLoadRequest实例，请求网络图并返回Data形式数据；
* TPG 主要功能：解码TPG格式图片并显示；即可用于显示普通图片，也可用于TPG图；
* SDWebImage-TPG 主要功能：支持SDWebImage显示TPG格式图片；


### SDK 导入
使用cocoapods的方式来进行导入。
根据实际项目需求在Podfile文件中集成所需要的模块：

~~~
 pod 'CloudInfinite',  #仅集成CloudInfinite模块
 pod 'CloudInfinite/TPG',    #仅集成TPG模块       
 pod 'CloudInfinite/SDWebImage-TPG',  #仅集成SDWebImage-TPG模块
 pod 'CloudInfinite/Loader', #仅集成Loader模块  
~~~


## 使用
CloudInfinite iOS SDK提供四种加载图片的方式下面将逐个介绍每一种加载方式的用户以及要集成的模块；

### 方式一 使用SDWebimage-TPG加载数据万象普通图片（推荐）
#### 集成 CloudInfinite ，SDWebImage-TPG模块；在CloudInfinite模块中构建出有万象数据图片基础功能的链接，使用SDWebImage自带的加载方法，示例代码：
	// 实例化CloudImage，用来构建请求图片请求连接；
	CloudImage * cloudImage = [CloudImage new];
	// 根据用户所选万象基础功能options 进行构建CIImageLoadRequest；
	CITransformation * transform = [[CITransformation alloc] initWithFormat:CIImageTypeJPG options:CILoadTypeUrlFooter];
	// 构建图片CIImageLoadRequest
	[cloudImage requestWithBaseUrl:[NSURL URLWithString:@"图片链接"] transform:tpgtransform request:^(CIImageLoadRequest * _Nonnull request) {

		//request 构建成功的CIImageLoadRequest实例，包含请求连接以及请求头，直接使用SDWebImage自带方法加载图片，如果需要设置请求头，则参考方式二
 	     [imageView sd_setImageWithURL:request.url placeholderImage:[UIImage imageNamed:@"placeholder"]];
	}];


### 方式二 使用SDWebimage-TPG加载TPG格式图片（推荐）
#### 集成 CloudInfinite，SDWebImage-TPG，TPG；示例代码：

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
#### 集成 CloudInfinite，Loader；示例代码：

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
#### 集成 CloudInfinite，Loader，TPG；示例代码：


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

