//
//  FaceCoreDataManager.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/14.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "FaceCoreDataManager.h"
#import "FaceImgHistory+CoreDataClass.h"

#define sqliteName @"faceCoreData.sqlite"

@implementation FaceCoreDataManager
{
    NSManagedObjectContext *managedContext;
}
static FaceCoreDataManager *instance = nil;

+ (instancetype)shareManager{
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        instance = [[[self class]alloc]init];
        [instance openDB];
    });
    return instance;
}

- (void)openDB{
    // 加载数据模型路径
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FaceHistory" withExtension:@"momd"];
    // 创建数据模型对象
    NSManagedObjectModel *managedModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:managedModel];
    
    // 定义数据库文件的路径
//    NSURL *dbURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@%@", FaceHistoryPath, sqliteName]]];
    NSURL *dbURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@%@", @"/Documents/", sqliteName]]];
    
    NSError *error = nil;
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dbURL options:nil error:&error];
    if(error == nil){
        NSLog(@"打开数据库文件成功");
    }else{
        NSLog(@"打开数据库文件失败 %@", error);
    }
    managedContext = [[NSManagedObjectContext alloc] init];
    managedContext.persistentStoreCoordinator = store;
}

- (id)createMO:(NSString *)entityName{
    NSManagedObject *managedObject =  [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:managedContext];
    return managedObject;
}

- (void)save:(NSManagedObject *)mo{
    // 添加到上下文容器
    [managedContext insertObject:mo];
    NSError *error = nil;
    if([managedContext save:&error]){
        NSLog(@"数据保存成功");
    }else{
        NSLog(@"数据保存失败 %@", error);
    }
}

- (NSArray *)query:(NSString *)entityName predicate:(NSPredicate *)predicate{
    if(entityName.length == 0){
        return nil;
    }
    // 关联查询条件
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    request.predicate = predicate;
    
    // 按时间排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"selTime" ascending:NO];
    [request setSortDescriptors:@[sort]];
    
    return [managedContext executeFetchRequest:request error:nil];
}

- (void)update:(NSManagedObject *)mo{
    NSError *error = nil;
    if([managedContext save:nil]){
        NSLog(@"修改成功");
    }else{
        NSLog(@"修改失败 %@", error);
    }
}

- (void)remove:(NSManagedObject *)mo{
    if(mo == nil){
        return;
    }
    [managedContext deleteObject:mo];
    NSError *error = nil;
    if([managedContext save:&error]){
        NSLog(@"删除成功");
    }else{
        NSLog(@"删除失败 %@", error);
    }
    
}

@end
