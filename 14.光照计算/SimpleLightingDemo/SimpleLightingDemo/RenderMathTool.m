//
//  RenderMathTool.m
//  SimpleLightingDemo
//
//  Created by Misaka on 2020/5/18.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "RenderMathTool.h"


/// 根据顶点创建三角形
TriangleStructure createTriangle(const VertexStructure vertex0, const VertexStructure vertex1, const VertexStructure vertex2) {
    TriangleStructure triangle;
    triangle.vertexs[0] = vertex0;
    triangle.vertexs[1] = vertex1;
    triangle.vertexs[2] = vertex2;
    return triangle;
}

/// 以点0为出发点，通过叉积计算三角形平面法向量
GLKVector3 trianglePlaneNormal(const TriangleStructure triangle) {
    //vectorA =  v1 - v0
    GLKVector3 vectorA = GLKVector3Subtract(triangle.vertexs[1].position,
                                            triangle.vertexs[0].position);
    //vectorB =  v2 - v0
    GLKVector3 vectorB = GLKVector3Subtract(triangle.vertexs[2].position,
                                            triangle.vertexs[0].position);
    //通过向量A和向量B的叉积求出平面法向量，单元化后返回
    return GLKVector3Normalize(GLKVector3CrossProduct(vectorA, vectorB));
}

/// 更新法线
void updateNormal(TriangleStructure triangles[TriangleCount]) {
    for (int i = 0; i < TriangleCount; i ++) {
        GLKVector3 newNormal = trianglePlaneNormal(triangles[i]);
        triangles[i].vertexs[0].normal = newNormal;
        triangles[i].vertexs[1].normal = newNormal;
        triangles[i].vertexs[2].normal = newNormal;
    }
}

/// 获取法线/光源线所有顶点
void getLinePoints(const TriangleStructure triangles[TriangleCount], GLKVector3 light, GLKVector3 linePoints[LineVertexCount]) {
    int triangleIndex = 0;
    int linePointIndex = 0;
    for (triangleIndex = 0; triangleIndex < TriangleCount; triangleIndex ++) {
        VertexStructure vertex0 = triangles[triangleIndex].vertexs[0];
        linePoints[linePointIndex ++] = vertex0.position;
        linePoints[linePointIndex ++] = GLKVector3Add(vertex0.position,GLKVector3MultiplyScalar(vertex0.normal,0.5));

        VertexStructure vertex1 = triangles[triangleIndex].vertexs[1];
        linePoints[linePointIndex ++] = vertex1.position;
        linePoints[linePointIndex ++] = GLKVector3Add(vertex1.position,GLKVector3MultiplyScalar(vertex1.normal,0.5));

        VertexStructure vertex2 = triangles[triangleIndex].vertexs[2];
        linePoints[linePointIndex ++] = vertex2.position;
        linePoints[linePointIndex ++] = GLKVector3Add(vertex2.position,GLKVector3MultiplyScalar(vertex2.normal,0.5));
    }
    /// 光源
    linePoints[linePointIndex ++] = light;
    linePoints[linePointIndex] = GLKVector3Make(0.0, 0.0, 0.0);
}


