/*********************************************************************************
*��Ȩ��			��Ѷ�Ƽ������ڣ����޹�˾
*�ļ���:			tpgDecoder.h
*����:			��ʫ��
*�汾:			v1.0
*����:			2017.11.08
*��������:		TPG����
**********************************************************************************/

#ifndef __TPGDECODER_H__
#define __TPGDECODER_H__

#ifndef WIN32
#define DLLEX __attribute__ ((visibility ("default")))

#else
#define DLLEX __declspec(dllexport)
#endif

#define MAX_LAYER_NUM	3
#define MAX_WIDTH	16383
#define MAX_HEIGHT  16383

#ifndef TPG_RAW_DATA_FORMAT
#define TPG_RAW_DATA_FORMAT

#define IMAGE_SUPPLEMENT_DATA 0x000001BA
#define IMAGE_USER_DATA 0x000001BD


typedef enum tagRawDataFormat
{
	FORMAT_YUV = 0,
	FORMAT_RGB = 1,
	FORMAT_BGR = 2,
	FORMAT_RGBA = 3,
	FORMAT_BGRA = 4,
	FORMAT_NV21 = 5,
	FORMAT_RGBA_BLEND_ALPHA = 6, //RGB*alpha
}enRawDataFormat;

typedef enum TPGStatusCode {
    TPG_STATUS_OK = 0,
    TPG_STATUS_OUT_OF_MEMORY,
    TPG_STATUS_INVALID_PARAM,
    TPG_STATUS_BITSTREAM_ERROR,
    TPG_STATUS_UNSUPPORTED_FEATURE,
    TPG_STATUS_SUSPENDED,
    TPG_STATUS_USER_ABORT,
    TPG_STATUS_NOT_ENOUGH_DATA,
    TPG_STATUS_INIT_ERROR
} TPGStatusCode;


typedef	enum enumImageMode
{
    emMode_Normal = 0,				//��̬ͼƬ��ʽ�����ΪRGB���ݣ�
    emMode_EncodeAlpha = 1,			//��Alphaͨ����̬ͼƬ��ʽ�����ΪRGBA���ݣ�
    emMode_BlendAlpha = 2,			//��Alphaͨ��������Alphaͨ��ֱ����RGB���ݺϳ��ˣ��������RGB���ݣ�
    emMode_Animation = 3,			//��̬ͼƬ��ʽ������Alpha��
	emMode_AnimationWithAlpha = 4,	//��̬ͼƬ��ʽ����Alpha��
}enumImageMode;

#endif

typedef struct _TPGFeatures
{
	int header_size;			//TPG�ļ�ͷ���ȣ�
    int width;					//TPGͼƬ���
    int height;					//TPGͼƬ�߶�
    enumImageMode image_mode;	//TPG�ļ�����
    int version;				//TPG�ļ���ʽ�汾
	int frame_count;			//TPG�ļ�������ͼ��֡������̬ͼƬΪ1
    int reserved[10];			//����λ
}TPGFeatures;

typedef struct _TPGOutFrame
{
	unsigned char* pOutBuf;		//���RGB���ݻ�������ַ 
	int bufsize;				// ��������С
    int dstWidth;				// ���ͼƬĿ�Ŀ��
    int dstHeight;				// ���ͼƬĿ�ĸ߶�
    enRawDataFormat fmt;		// ���ͼƬ��������
    int delayTime;				// ��ǰͼƬ��ʾ���ӳ�ʱ�䣨ֻ�Զ�̬ͼƬ��Ч��
}TPGOutFrame;

#ifdef __cplusplus
extern "C" {
#endif

	//==================================================================
	//��������	TPGDecCreate
	//���ܣ�		����TPG������
	//���������	pData	������TPG����
	//			len[in]	TPG��������
	//����ֵ��	���ͣ�void*)
	//          ����TPG���������������������ɹ�����NULL��
	//�޸ļ�¼��
	//==================================================================
    DLLEX void* TPGDecCreate(const unsigned char* pData, int len);


	//==================================================================
	//��������	TPGDecDestroy
	//���ܣ�		����TPG������
	//���������
	//			h	TPG���������
	//����ֵ��	���ͣ�void)
	//�޸ļ�¼��
	//==================================================================
	DLLEX void TPGDecDestroy(void* h);

	//==================================================================
	//��������	TPGDecodeImage
	//���ܣ�		����һ֡ͼ��
	//���������
	//			hDec	TPG���������
	//			pData	������TPG����
	//			len	    TPG��������
	//			index	����֡��������̬ͼƬ��ֵ��Ϊ0�����ڶ�ͼ����ʾ�����index֡ͼ��
	//���������
	//			pDecFrame	�������֡��������ߵ���Ϣ
	//����ֵ��	���ͣ�TPGStatusCode)
	//          ����ɹ�����TPG_STATUS_OK�����򷵻ض�Ӧ�����롣
	//�޸ļ�¼��
	//==================================================================
	DLLEX TPGStatusCode TPGDecodeImage(void* hDec, const unsigned char* pData, int len, int index, TPGOutFrame *pDecFrame);

	//==================================================================
	//��������	TPGParseHeader
	//���ܣ�		��������ͷ�ļ�
	//���������
	//			pData	������TPG����
	//			len	    TPG��������
	//���������
	//			pFeatures	���TPG�ļ�����������Ϣ
	//����ֵ��	���ͣ�TPGStatusCode)
	//          ��ǰ�ļ�ΪTPG�ļ�����TPG_STATUS_OK�����򷵻ض�Ӧ�����롣
	//�޸ļ�¼��
	//==================================================================
	DLLEX TPGStatusCode TPGParseHeader(const unsigned char* pData, int len, TPGFeatures* pFeatures);

	//==================================================================
	//��������	TPGGetDelayTime
	//���ܣ�		��ȡ��ǰ֡ͼ�����ʾ�ӳ�ʱ�䣨�ýӿ�ֻ�ж�̬ͼƬ��Ч��
	//���������
	//			hDec	TPG���������
	//			pData	������TPG����
	//			len	    TPG��������
	//			index	����֡��������̬ͼƬ��ֵ��Ϊ0�����ڶ�ͼ����ʾ�����index֡ͼ��
	//���������
	//			pDelayTime	��Ӧ֡����ʾ�ӳ�ʱ��
	//����ֵ��	���ͣ�TPGStatusCode)
	//          ��ȡ����TPG_STATUS_OK�����򷵻ض�Ӧ�����롣
	//�޸ļ�¼��
	//==================================================================
	DLLEX TPGStatusCode TPGGetDelayTime(void* hDec, const unsigned char* pData, int len, int index, int* pDelayTime);

	//==================================================================
	//��������	TPGCanDecode
	//���ܣ�		��⵱ǰ���������Ƿ��㹻����
	//���������
	//			hDec	TPG���������
	//			pData	������TPG����
	//			len	    TPG��������
	//			index	����֡��������̬ͼƬ��ֵ��Ϊ0�����ڶ�ͼ����ʾ�����index֡ͼ��
	//����ֵ��	���ͣ�TPGStatusCode)
	//			��index֡�ܽ��뷵��TPG_STATUS_OK�����򷵻ض�Ӧ�����롣
	//�޸ļ�¼��
	//==================================================================
	DLLEX TPGStatusCode TPGCanDecode(void* hDec,  const unsigned char* pData, int len, int index);

	//==================================================================
	//��������	TPGGetAdditionalInfo
	//���ܣ�		��ȡTPG�����е��û�������Ϣ(����EXIF��)
	//���������
	//			hDec		TPG���������
	//			pInData		TPG����
	//			nInDatalen	TPG��������
	//			nIdentity	������Ϣ��ʶ
	//���������
	//			pOutData	������Ϣ�׵�ַ�����û�з���NULL�������ڴ治��ҪӦ�ò����
	//			pOutDataLen	��Ӧ֡����ʾ�ӳ�ʱ�䣨������Ϣ���ȣ�
	//����ֵ��	���ͣ�TPGStatusCode)
	//          ��ȡ����Ӧ������Ϣ����TPG_STATUS_OK�����򷵻ض�Ӧ�����롣
	//�޸ļ�¼��
	//==================================================================
	DLLEX TPGStatusCode TPGGetAdditionalInfo(void* hDec, const unsigned char* pInData, int nInDatalen, int nIdentity, const unsigned char** pOutData, int* pOutDataLen);

	//==================================================================
	//��������	TPGDecGetVersion
	//���ܣ�		��ȡTPG�������汾��
	//���������	��
	//����ֵ��	���ͣ�int)
	//			���ض�Ӧ�汾�š�
	//�޸ļ�¼��
	//==================================================================
	DLLEX int TPGDecGetVersion();
#ifdef __cplusplus
};
#endif


#endif	// __TPGDEC_H__
