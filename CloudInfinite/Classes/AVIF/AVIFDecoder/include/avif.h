// Copyright 2019 Joe Drago. All rights reserved.
// SPDX-License-Identifier: BSD-2-Clause

#ifndef AVIF_AVIF_H
#define AVIF_AVIF_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// ---------------------------------------------------------------------------
// Export macros

// AVIF_BUILDING_SHARED_LIBS should only be defined when libavif is being built
// as a shared library.
// AVIF_DLL should be defined if libavif is a shared library. If you are using
// libavif as CMake dependency, through CMake package config file or through
// pkg-config, this is defined automatically.
//
// Here's what AVIF_API will be defined as in shared build:
// |       |        Windows        |                  Unix                  |
// | Build | __declspec(dllexport) | __attribute__((visibility("default"))) |
// |  Use  | __declspec(dllimport) |                                        |
//
// For static build, AVIF_API is always defined as nothing.

#if defined(_WIN32)
#define AVIF_HELPER_EXPORT __declspec(dllexport)
#define AVIF_HELPER_IMPORT __declspec(dllimport)
#elif defined(__GNUC__) && __GNUC__ >= 4
#define AVIF_HELPER_EXPORT __attribute__((visibility("default")))
#define AVIF_HELPER_IMPORT
#else
#define AVIF_HELPER_EXPORT
#define AVIF_HELPER_IMPORT
#endif

#if defined(AVIF_DLL)
#if defined(AVIF_BUILDING_SHARED_LIBS)
#define AVIF_API AVIF_HELPER_EXPORT
#else
#define AVIF_API AVIF_HELPER_IMPORT
#endif // defined(AVIF_BUILDING_SHARED_LIBS)
#else
#define AVIF_API
#endif // defined(AVIF_DLL)

#define NEW_INTERFACE 1
// ---------------------------------------------------------------------------
// Constants


#if NEW_INTERFACE
typedef struct AVIFFeature { // For now, we only support width,height and frameCount
	int width;    
	int height;
	int headerSize;
	int imageMode;
	int frameCount;
	int version;
}AVIFFeature;

typedef struct AVIFOutFrame {
	int32_t * pOutBuf;
	int32_t bufsize;
	int32_t dstWidth;
	int32_t dstHeight;
	int32_t fmt;
	int32_t delayTime;
}AVIFOutFrame;

AVIF_API int64_t CreateDecoder(uint8_t * pStream, long size);
AVIF_API int64_t CreateDecoder2(char * inputFilename);
AVIF_API int ParseHeader(uint8_t * pStream, long size, AVIFFeature *avifFeature);
AVIF_API int ParseHeader2(char inputFilename[], AVIFFeature *avifFeature);

AVIF_API void CloseDecoder(int64_t hDecoder);
AVIF_API int DecodeNthImage(int64_t hDecoder, int32_t frameIndex );
AVIF_API int DecodeImage(int64_t hDecoder, int32_t frameindex, AVIFOutFrame * avifOutFrame);
//AVIF_API int CheckAPI(void);

AVIF_API int GetDelayNthImage(int64_t hDecoder, int32_t frameindex);
#endif


#ifdef __cplusplus
} // extern "C"
#endif

#endif // ifndef AVIF_AVIF_H
