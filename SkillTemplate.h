//
//  SkillTemplate.h
//  PlayerProgressTracker
//
//  Created by Vlad Antipin on 28.01.14.
//  Copyright (c) 2014 WierdMasks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreDataClass.h"

@class Skill, SkillTemplate, CoreDataClass, Pic;

@interface SkillTemplate : CoreDataClass;

typedef enum SkillClassType : int16_t
{
    AdvancedSkillType = 0,
    MagicSkillType = 1,
    RangeSkillType = 2,
    MeleeSkillType = 3,
    PietySkillType = 4,
    BasicSkillType = 5,
    LastElementInEnum = 6,
} SkillClassesType;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * skillDescription;
@property (nonatomic, retain) Pic *icon;
@property (nonatomic) float levelBasicBarrier;
@property (nonatomic) float levelProgression;
@property (nonatomic) float levelGrowthGoesToBasicSkill;
@property (nonatomic) int16_t skillStartingLvl;
@property (nonatomic) SkillClassesType skillEnumType;
@property (nonatomic, retain) NSSet *skillsFromThisTemplate;
@property (nonatomic, retain) SkillTemplate *basicSkillTemplate;
@property (nonatomic, retain) NSSet *subSkillsTemplate;
@end

@interface SkillTemplate (CoreDataGeneratedAccessors)

- (void)addSkillsFromThisTemplateObject:(Skill *)value;
- (void)removeSkillsFromThisTemplateObject:(Skill *)value;
- (void)addSkillsFromThisTemplate:(NSSet *)values;
- (void)removeSkillsFromThisTemplate:(NSSet *)values;

- (void)addSubSkillsTemplateObject:(SkillTemplate *)value;
- (void)removeSubSkillsTemplateObject:(SkillTemplate *)value;
- (void)addSubSkillsTemplate:(NSSet *)values;
- (void)removeSubSkillsTemplate:(NSSet *)values;

+(SkillTemplate *)newSkillTemplateWithUniqName:(NSString *)name
                               withDescription:(NSString *)skillDescription
                                 withSkillIcon:(UIImage *)icon
                            withBasicXpBarrier:(float)basicXpBarrier
                          withSkillProgression:(float)skillProgression
                      withBasicSkillGrowthGoes:(float)basicSkillGrowthGoes
                                 withSkillType:(SkillClassesType)skillClassType
                        withDefaultStartingLvl:(int)startingLvl
                       withParentSkillTemplate:(SkillTemplate *)basicSkillTemplate
                                   withContext:(NSManagedObjectContext *)context;

+(NSArray *)fetchAllSkillTemplatesWithContext:(NSManagedObjectContext *)context;

+(BOOL)deleteSkillTemplateWithName:(NSString *)skillTemplateName withContext:(NSManagedObjectContext *)context;

+(NSString *)entityNameForSkillTemplate:(SkillTemplate *)skillTemplate;
+(NSString *)entityNameForSkillEnum:(int16_t)skillEnum;
@end
