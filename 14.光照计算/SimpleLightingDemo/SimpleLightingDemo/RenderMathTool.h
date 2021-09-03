//
//  RenderMathTool.h
//  SimpleLightingDemo
//
//  Created by Misaka on 2020/5/18.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import <GLKit/GLKit.h>

/// 三角形数目
#define TriangleCount (8)
/// 法线顶点数目
#define NormalVertexCount (TriangleCount * 3 * 2)
/// 绘制线条顶点数目
#define LineVertexCount (NormalVertexCount + 2)

/// 顶点
typedef struct {
    GLKVector3 position;//顶点
    GLKVector3 normal;//法线
} VertexStructure;

/// 三角形
typedef struct {
    VertexStructure vertexs[3];//三角形3个顶点
} TriangleStructure;

static const VertexStructure vertex0 = {{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const VertexStructure vertex1 = {{-0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const VertexStructure vertex2 = {{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const VertexStructure vertex3 = {{ 0.0,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const VertexStructure vertex4 = {{ 0.0,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const VertexStructure vertex5 = {{ 0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const VertexStructure vertex6 = {{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const VertexStructure vertex7 = {{ 0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const VertexStructure vertex8 = {{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};

/// 根据顶点创建三角形
TriangleStructure createTriangle(const VertexStructure vertex0, const VertexStructure vertex1, const VertexStructure vertex2);
/// 更新法线
void updateNormal(TriangleStructure triangles[TriangleCount]);
/// 获取法线/光源线所有顶点
void getLinePoints(const TriangleStructure triangles[TriangleCount], GLKVector3 light, GLKVector3 linePoints[LineVertexCount]);
