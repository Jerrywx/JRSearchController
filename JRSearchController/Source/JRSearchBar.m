//
//  JRSearchBar.m
//  附加题
//
//  Created by Jerry on 15/6/12.
//  Copyright (c) 2015年 Jerry. All rights reserved.
//

#import "JRSearchBar.h"

@implementation JRSearchBar

- (NSMutableArray *)searchTest:(NSString *)searchText InArray:(NSArray *)array {
	
	NSMutableArray *tmpArray = [NSMutableArray array];

	for (int i=0; i<array.count; i++) {
		
		NSString *larg1 = [searchText uppercaseString];
		NSString *larg2 = [array[i] uppercaseString];
		
		if ([larg2 containsString:larg1])
		{
			[tmpArray addObject: array[i]];
		}
	}

	return tmpArray;
}

@end
