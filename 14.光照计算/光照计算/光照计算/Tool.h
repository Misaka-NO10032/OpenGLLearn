//
//  Tool.h
//  光照计算
//
//  Created by Misaka on 2020/5/25.
//  Copyright © 2020 Misaka. All rights reserved.
//

#ifndef Tool_h
#define Tool_h

#include <stdio.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

long getFileContent(char *buffer, long len, const char *filePath);

GLuint createGLProgram(const char *vertext, const char *frag);

GLuint createGLProgramFromFile(const char *vertextPath, const char *fragPath);

static GLuint createGLShader(const char *shaderText, GLenum shaderType);

GLuint createVBO(GLenum target, int usage, int datSize, void *data);

GLuint createTexture2D(GLenum format, int width, int height, void *data);

#endif /* Tool_h */
