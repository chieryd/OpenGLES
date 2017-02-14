//
//  glView.m
//  FirstOpenGLES
//
//  Created by chiery on 2017/2/10.
//  Copyright © 2017年 qunar. All rights reserved.
//  使用全新的openGL ES3.0的框架来完成样例的搭建

#import "glView.h"
#import <OpenGLES/ES3/gl.h>

typedef struct {
    float posiztion[3];
    float color[4];
} Vertex;

@interface glView (){
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    CAEAGLLayer *_glLayer;
    EAGLContext *_context;
}
@end

@implementation glView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupContext];
    [self setupLayer];
    [self setupBuffers];
    [self draw];
    [self render];
}

- (void)setupContext {
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 3.0 context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        _context = nil;
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupBuffers {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_glLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)setupLayer
{
    _glLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _glLayer.opaque = YES;
    
    _glLayer.contentsScale = 1.0f;
}

- (void)draw {
    
    char vShaderStr[] =
    "#version 300 es                          \n"
    "layout(location = 0) in vec4 vPosition;  \n"
    "layout(location = 1) in vec4 vColor;     \n"
    "out vec4 v_color;                        \n"
    "void main()                              \n"
    "{                                        \n"
    "   gl_Position = vPosition;              \n"
    "   v_color = vColor;                     \n"
    "}                                        \n";
    
    char fShaderStr[] =
    "#version 300 es                              \n"
    "precision mediump float;                     \n"
    "in vec4 v_color;                             \n"
    "out vec4 fragColor;                          \n"
    "void main()                                  \n"
    "{                                            \n"
    "   fragColor = v_color;                      \n"
    "}                                            \n";
    
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint programObject;
    GLint linked;
    
    vertexShader = loadShader(GL_VERTEX_SHADER, vShaderStr);
    fragmentShader = loadShader(GL_FRAGMENT_SHADER, fShaderStr);
    
    programObject = glCreateProgram();
    
    // 检测程序是否被创建
    if (programObject == 0) {
        NSLog(@"程序创建失败");
        return;
    }
    
    glAttachShader(programObject, vertexShader);
    glAttachShader(programObject, fragmentShader);
    
    // 连接程序
    glLinkProgram(programObject);
    
    // 检查程序的状态
    glGetProgramiv(programObject, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(programObject, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 0) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(programObject, infoLen, NULL, infoLog);
            NSLog(@"程序连接出错了：%s",infoLog);
            free(infoLog);
        }
        glDeleteProgram(programObject);
        return;
    }
    
    glUseProgram(programObject);
    glClearColor ( 0.0f, 1.0f, 0.0f, 1.0f );
}

- (void)render {
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    //
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    const Vertex vertices[] = {
        {{1, -1, 0},{1, 0, 0 , 1}},
        {{1, 1, 0},{0, 1, 0, 1}},
        {{-1, 1, 0},{0, 0, 1, 1}},
        {{-1, -1, 0},{0, 0, 0, 1}}
    };
    
    const GLubyte indices[] = {
        0,1,2,
        2,3,0
    };
    
    // 将顶点数据绑定到当前缓存中去
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 将对应顶点的绘制索引绑定到缓存中取
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float)*3));
    
    // 一定要启用自定义设置的顶点属性，默认这个属性是disable的
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    
    // 参考的连接是http://bbs.tairan.com/article-11-3.html
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, 0);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    
    // 这么写存在的优点在于，缓存了顶点位置信息和颜色数据，，下次绘制的时候直接从缓存中就可以完成，不用做过多的计算
}


GLuint loadShader(GLenum type, const char *shaderSrc) {
    GLuint shader;
    GLint compiled;
    
    // 创建一个shader句柄
    shader = glCreateShader(type);
    
    // 检测shader是否创建成功
    if (shader == 0) {
        NSLog(@"shader创建失败");
        return 0;
    }
    
    // 加载着色器资源,这里没有指定shader的length默认到加载到\0结束
    glShaderSource(shader, 1, &shaderSrc, NULL);
    
    // 编译着色器
    glCompileShader(shader);
    
    // 检查着色器的编译结果
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
    if (!compiled) {
        GLint infoLength = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 1) {
            char *infoLog = malloc(sizeof(char) * infoLength);
            glGetShaderInfoLog(shader, infoLength, NULL, infoLog);
            NSLog(@"编译出错了-打印的出错信息为:%s",infoLog);
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

@end
