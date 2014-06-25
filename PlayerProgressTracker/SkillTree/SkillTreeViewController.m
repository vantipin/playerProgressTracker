//
//  SkillTreeViewController.m
//  PlayerProgressTracker
//
//  Created by Vlad Antipin on 14.05.14.
//  Copyright (c) 2014 WierdMasks. All rights reserved.
//

#import "SkillTreeViewController.h"
#import "SkillTemplate.h"
#import "SkillManager.h"
#import "DefaultSkillTemplates.h"

static float minimalMarginBetweenTrees = 100;
static float minimalMarginBetweenNodesX = 50;
static float minimalMarginBetweenNodesY = 110;
static float borderSize = 100;
static float nodeDiameter = 200;

static NSString *emptyParentKey = @"emptyParent";

@interface SkillTreeViewController ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UIView *containerForContainerView; //Why? bug with centering zooming


@property (nonatomic) NSMutableArray *trees;

@property (nonatomic) NSMutableDictionary *treeNodeWidthForTreeArrayObject;
@property (nonatomic) NSMutableDictionary *treeSpacesWidthForTreeArrayObject;

@property (nonatomic) NSMutableDictionary *nodesOnSingleLevelForLevelArrayObject;

@property (nonatomic) NSMutableDictionary *sectionIndexesForSkillParentName;
@property (nonatomic) NSMutableDictionary *nodeIndexesForSkillNames;
@property (nonatomic) long treeHeight;

@property (nonatomic) NSMutableArray *allExistingNodes;

@end

@implementation SkillTreeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTree];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.view.autoresizesSubviews = true;
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.scrollView.autoresizesSubviews = true;
    
    
    float width = 0 + borderSize * 2;
    for (NSMutableArray *tree in self.trees) {
        NSInteger currentTreeWidth = [[self.treeNodeWidthForTreeArrayObject objectForKey:tree] integerValue];
        
        NSInteger currentTreeMaxWidthSpacing = [[self.treeSpacesWidthForTreeArrayObject objectForKey:tree] integerValue];
        width += (currentTreeWidth * nodeDiameter) + (currentTreeMaxWidthSpacing * minimalMarginBetweenNodesX);
    }
    width += (self.trees.count - 1) * minimalMarginBetweenTrees;
    
    float height = (self.treeHeight * (nodeDiameter + minimalMarginBetweenNodesY)) + minimalMarginBetweenNodesY;
    self.scrollView.contentSize = CGSizeMake(width, height);
    
    self.containerView.frame = CGRectMake(0, 0, width, height);
    self.containerForContainerView.frame = self.containerView.frame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self resetSkillNodes];
    [[SkillManager sharedInstance] subscribeForSkillsChangeNotifications:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateScrollViewZoomAnimated:true];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[SkillManager sharedInstance] unsubscribeForSkillChangeNotifications:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //NSLog(@"%d",toInterfaceOrientation);
    [self updateScrollViewZoomAnimated:true];
}

-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        self.scrollView.delegate = self;
        [self.view addSubview:self.scrollView];
    }
    return _scrollView;
}

-(UIView *)containerView
{
    if (!_containerView) {
        _containerView = [UIView new];
        [self.containerForContainerView addSubview:self.containerView];
    }
    return _containerView;
}

-(UIView *)containerForContainerView
{
    if (!_containerForContainerView) {
        _containerForContainerView = [UIView new];
        [self.scrollView addSubview:self.containerForContainerView];
    }
    return _containerForContainerView;
}

-(void)setCharacter:(Character *)character
{
    if (character) {
        _character = character;
    }
}

-(NSMutableArray *)trees
{
    if (!_trees) {
        _trees = [NSMutableArray new];
    }
    
    return _trees;
}

-(NSMutableDictionary *)nodesOnSingleLevelForLevelArrayObject
{
    if (!_nodesOnSingleLevelForLevelArrayObject) {
        _nodesOnSingleLevelForLevelArrayObject = [NSMutableDictionary new];
    }
    
    return _nodesOnSingleLevelForLevelArrayObject;
}

-(NSMutableDictionary *)sectionIndexesForSkillParentName
{
    if (!_sectionIndexesForSkillParentName) {
        _sectionIndexesForSkillParentName = [NSMutableDictionary new];
    }
    
    return _sectionIndexesForSkillParentName;
}

-(NSMutableDictionary *)treeNodeWidthForTreeArrayObject
{
    if (!_treeNodeWidthForTreeArrayObject) {
        _treeNodeWidthForTreeArrayObject = [NSMutableDictionary new];
    }
    
    return _treeNodeWidthForTreeArrayObject;
}


-(NSMutableDictionary *)treeSpacesWidthForTreeArrayObject
{
    if (!_treeSpacesWidthForTreeArrayObject) {
        _treeSpacesWidthForTreeArrayObject = [NSMutableDictionary new];
    }
    
    return _treeSpacesWidthForTreeArrayObject;
}

-(NSMutableDictionary *)nodeIndexesForSkillNames
{
    if (!_nodeIndexesForSkillNames) {
        _nodeIndexesForSkillNames = [NSMutableDictionary new];
    }
    return _nodeIndexesForSkillNames;
}

-(void)updateScrollViewZoomAnimated:(BOOL)animated
{
//    BOOL isLandscape = false;
//    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
//        isLandscape = false;
//    }
//    else {
//        isLandscape = true;
//    }
    

    //since orientation change allowed zoom scale should be reset in order to calculate following scales correctly
    [self.scrollView setZoomScale:1.0f];
    
    
    float scrollViewRealWidth = self.scrollView.frame.size.width;
    float scrollViewRealHeight = self.scrollView.frame.size.height;
    
//    NSLog(@"width  %f",scrollViewRealWidth);
//    NSLog(@"height %f",scrollViewRealHeight);
    
    float scaleWidth = scrollViewRealWidth / self.scrollView.contentSize.width;
    float scaleHeight = scrollViewRealHeight / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    CGFloat currentScale = MIN(scrollViewRealHeight, scrollViewRealWidth) / self.scrollView.contentSize.height;//MAX(scaleWidth, scaleHeight)
    
    self.scrollView.scrollEnabled = true;
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.0f;
    [self.scrollView setZoomScale:currentScale  animated:animated];
    
    //NSLog(@"\nmin %f \nmax %f",self.scrollView.minimumZoomScale,self.scrollView.maximumZoomScale);
}

#pragma mark -
#pragma build tree methods
-(void)initTree
{
    self.trees = [NSMutableArray new];
    self.allExistingNodes = [NSMutableArray new];
    self.treeHeight = 0;
    self.treeNodeWidthForTreeArrayObject = nil;
    self.treeSpacesWidthForTreeArrayObject = nil;
    self.sectionIndexesForSkillParentName = nil;
    self.nodesOnSingleLevelForLevelArrayObject = nil;
    
    NSArray *rootSkills = [[DefaultSkillTemplates sharedInstance] allBasicSkillTemplates];
    
    for (SkillTemplate *rootSkill in rootSkills) {
        NSMutableArray *tree = [NSMutableArray new];
        NSInteger indexOfTree = self.trees.count;
        [self.trees addObject:tree];
        
        NSMutableArray *rootLevel = [NSMutableArray new];
        NSMutableArray *rootSection = [NSMutableArray new];
        [tree addObject:rootLevel];
        [rootLevel addObject:rootSection];
        [rootSection addObject:rootSkill];
        
        
        [self addSubSkillsFrom:rootSkill withTreeIndex:indexOfTree];
        
        NSInteger treeWidth = 0;
        NSInteger treeCurrentSpaces = 0;
        for (NSMutableArray *level in tree) {
            NSInteger levelWidth = 0;
            NSInteger levelSpaces = 0;
            for (NSMutableArray *section in level) {
                levelWidth += section.count;
                levelSpaces += section.count;
            }
            levelSpaces --;
            levelSpaces += level.count;
            
            //levelWidth += level.count - 1 ? : 0;
            [self.nodesOnSingleLevelForLevelArrayObject setObject:[NSNumber numberWithInteger:levelSpaces] forKey:level];
            if (levelWidth > treeWidth) {
                treeWidth = levelWidth;
            }
            if (levelSpaces > treeCurrentSpaces) {
                treeCurrentSpaces = levelSpaces;
            }
        }
        [self.treeNodeWidthForTreeArrayObject setObject:[NSNumber numberWithInteger:treeWidth] forKey:tree];
        [self.treeSpacesWidthForTreeArrayObject setObject:[NSNumber numberWithInteger:treeCurrentSpaces] forKey:tree];
    }
}


-(void)addSubSkillsFrom:(SkillTemplate *)parentSkill withTreeIndex:(NSInteger)index
{
    for (SkillTemplate *skill in parentSkill.subSkillsTemplate) {
        [self addSkillInTreeHierachy:skill withTreeIndex:index];
        [self addSubSkillsFrom:skill withTreeIndex:index];
    }
}

-(void)addSkillInTreeHierachy:(SkillTemplate *)skill withTreeIndex:(NSInteger)index
{
    NSInteger positionYInTree = [[SkillManager sharedInstance] countPositionYInATreeForSkill:skill];
    if (positionYInTree > self.treeHeight) {
        self.treeHeight = positionYInTree;
    }
    
    NSMutableArray *tree = [self.trees objectAtIndex:(NSUInteger)index];
    if (positionYInTree == tree.count) {
        NSMutableArray *missingNextLevel = [NSMutableArray new];
        [tree addObject:missingNextLevel];
    }
    else if (positionYInTree > tree.count) {
        NSInteger notYetInitedLevelsOfTree = positionYInTree - tree.count;
        for (int i = 0; i < notYetInitedLevelsOfTree; i++) {
            [tree addObject:[NSMutableArray new]]; //add level to store tree nodes
        }
    }
    
    //current level
    NSMutableArray *currentLevel = [tree objectAtIndex:(positionYInTree - 1)];
    
    //current section
    NSString *parentName = skill.basicSkillTemplate ? skill.basicSkillTemplate.name : emptyParentKey;
    if (![self.sectionIndexesForSkillParentName objectForKey:parentName]) {
        
        NSMutableArray *newSection = [NSMutableArray new];
        [self.sectionIndexesForSkillParentName setObject:[NSNumber numberWithUnsignedInt:currentLevel.count] forKey:parentName];
        [currentLevel addObject:newSection];
    }
    NSUInteger sectionIndex = [[self.sectionIndexesForSkillParentName objectForKey:parentName] unsignedIntegerValue];
    
    NSMutableArray *section = [currentLevel objectAtIndex:sectionIndex];
    [section addObject:skill];
}

-(void)resetSkillNodes
{
    if (self.character) {
        for (NodeViewController *subController in self.childViewControllers) {
            [subController removeFromParentViewController];
        }
        for (UIView *node in self.containerView.subviews) {
            [node removeFromSuperview];
        }
        
        
        NSUInteger treeMargin = 0;
        for (NSMutableArray *tree in self.trees) {
            NSUInteger thisTreeGreatestSectionMargin = 0;
            NSInteger treeWidth = [[self.treeNodeWidthForTreeArrayObject objectForKey:tree] integerValue];
            for (NSMutableArray *level in tree) {
                NSInteger levelWidth = [[self.nodesOnSingleLevelForLevelArrayObject objectForKey:level] integerValue];
                NSUInteger sectionMargin = 0;
                for (NSMutableArray *section in level) {
                    for (SkillTemplate *skillTemplate in section) {
                        Skill *skill = [[SkillManager sharedInstance] getOrAddSkillWithTemplate:skillTemplate withCharacter:self.character];
                        
                        float nodeX;
                        if (treeWidth > levelWidth) {
                            nodeX = borderSize + treeMargin + (((float)treeWidth) / ((float)levelWidth + 1) * ([section indexOfObject:skillTemplate] + 1)) * (nodeDiameter + minimalMarginBetweenNodesX) - (nodeDiameter + minimalMarginBetweenNodesX);
                            
                        }
                        else {
                            nodeX = borderSize + treeMargin + sectionMargin + [section indexOfObject:skillTemplate] * (nodeDiameter + minimalMarginBetweenNodesX);
                        }
                        float nodeY = ([tree indexOfObject:level] * (nodeDiameter + minimalMarginBetweenNodesY)) + minimalMarginBetweenNodesY;
                        CGRect skillNodeFrame = CGRectMake(nodeX, nodeY, nodeDiameter, nodeDiameter);
                        NodeViewController *newSkillNode = [NodeViewController getInstanceFromStoryboardWithFrame:skillNodeFrame];
                        newSkillNode.skill = skill;
                        [self addChildViewController:newSkillNode];
                        [self.containerView addSubview:newSkillNode.view];
                        newSkillNode.delegate = self;
                        
                        [self.nodeIndexesForSkillNames setObject:newSkillNode forKey:skillTemplate.name];
                        if (skillTemplate.basicSkillTemplate) {
                            if ([self.nodeIndexesForSkillNames valueForKey:skillTemplate.basicSkillTemplate.name]) {
                                
                                [newSkillNode setParentNodeLink:[self.nodeIndexesForSkillNames valueForKey:skillTemplate.basicSkillTemplate.name] placeInView:self.containerView addToController:self];
                            }
                        }
                        [self.allExistingNodes addObject:newSkillNode];
                        
                    }
                    sectionMargin += section.count * (nodeDiameter + minimalMarginBetweenNodesX) + minimalMarginBetweenNodesX;
                    thisTreeGreatestSectionMargin = (sectionMargin > thisTreeGreatestSectionMargin) ? sectionMargin : thisTreeGreatestSectionMargin;
                }
            }
            treeMargin += thisTreeGreatestSectionMargin + minimalMarginBetweenTrees;
        }
    }
}


-(void)refreshSkillvalues;
{
    [self refreshSkillvaluesWithReloadingSkills:false];
}

-(void)refreshSkillvaluesWithReloadingSkills:(BOOL)needReload;
{
    for (NodeViewController *node in self.allExistingNodes) {
        if (needReload) {
            node.skill = nil;
        }
        [node updateInterface];
    }
}


#pragma mark UIScrollViewDelegate methods
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerForContainerView;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}


- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.containerForContainerView.frame;

    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.containerForContainerView.frame = contentsFrame;

}


#pragma mark NodeViewControllerProtocol methods
-(Skill *)needNewSkillObjectWithTemplate:(SkillTemplate *)skillTemplate
{
    Skill *skill;
    if (self.character) {
        skill = [[SkillManager sharedInstance] getOrAddSkillWithTemplate:skillTemplate withCharacter:self.character];
    }
    return skill;
}

-(void)didSwipNodeDown:(NodeViewController *)node
{
    [[SkillManager sharedInstance] removeXpPoints:1.0f toSkill:node.skill];
}

-(void)didSwipNodeUp:(NodeViewController *)node
{
    
    [[SkillManager sharedInstance] addXpPoints:1.0f toSkill:node.skill];
}

-(void)didTapNode:(NodeViewController *)node
{
    NSLog(@"did tap node %@",node.skill.skillTemplate.name);
    [[SkillManager sharedInstance] showDescriptionForSkillTemplate:node.skill.skillTemplate inView:self.scrollView.superview];
}

-(void)didTapNodeLevel:(NodeViewController *)node
{
    NSLog(@"did tap level of node %@",node.skill.skillTemplate.name);
}


#pragma mark SkillChangeProtocol
-(void)didChangeExperiencePointsForSkill:(Skill *)skill
{
    NodeViewController *node = [self.nodeIndexesForSkillNames objectForKey:skill.skillTemplate.name];
    if (node) {
        [node updateInterface];
        
        [UIView animateWithDuration:0.5 animations:^{
            node.skillButton.highlighted = true;
        } completion:^(BOOL success){
            [UIView animateWithDuration:0.1 animations:^{
                node.skillButton.highlighted = false;
            }];
        }];
    }
}

-(void)didChangeSkillLevel:(Skill *)skill
{
    NodeViewController *node = [self.nodeIndexesForSkillNames objectForKey:skill.skillTemplate.name];
    if (node) {
        for (Skill *subSkill in node.skill.subSkills) {
            [self checkForUpdateSubskillsOf:subSkill];
        }
    }
}


-(void)checkForUpdateSubskillsOf:(Skill *)skill
{
    NodeViewController *node = [self.nodeIndexesForSkillNames objectForKey:skill.skillTemplate.name];
    if (node) {
        [node updateInterface];
        
        [UIView animateWithDuration:0.5 animations:^{
            node.skillButton.highlighted = true;
        } completion:^(BOOL success){
            [UIView animateWithDuration:0.1 animations:^{
                node.skillButton.highlighted = false;
            }];
        }];
        
        for (Skill *subSkill in node.skill.subSkills) {
            [self checkForUpdateSubskillsOf:subSkill];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end