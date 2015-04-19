//
//  AddInterestViewController.m
//  Findy
//
//  Created by iPhone on 8/7/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "AddInterestViewController.h"
#import "DataManager.h"
#import "FindyAPI.h"

@interface AddInterestViewController ()

@end

@implementation AddInterestViewController

@synthesize popularArray;

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
	// Do any additional setup after loading the view.
    UIImageView *navigationBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IOS7) ? @"NavigationBar7.png" : @"NavigationBar.png"]];
    [navigationBar setFrame:CGRectMake(0, 0, 320.f, 44.f + [DataManager sharedManager].fiOS7StatusHeight)];
     
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 30.f, 30.f)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShoutOut"]) {
        UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextButton setImage:[UIImage imageNamed:@"DoneButton.png"] forState:UIControlStateNormal];
        [nextButton setFrame:CGRectMake(263.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 49.f, 30.f)];
        [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
    }
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:@"Add Activities"];
    [self.view addSubview:lblTitle];
    
    interestArray = [[NSMutableArray alloc] init];
    removeCraze = [[NSMutableArray alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
    fArray = [[NSMutableArray alloc] initWithObjects:@"Archery", @"Cycling", @"Fitness and Workout", @"Golf", @"Hiking", @"Kiteboarding", @"Martial Arts", @"Mountain biking", @"Photography", @"Rock climbing", @"Running", @"Salsa dancing", @"Scuba diving", @"Surfing", @"Tennis", @"Yoga", nil];
    ppArray = [[NSMutableArray alloc] initWithObjects:@"Archery", @"Cycling", @"Fitness and Workout", @"Golf", @"Hiking", @"Kiteboarding", @"Martial Arts", @"Mountain biking", @"Photography", @"Rock climbing", @"Running", @"Salsa dancing", @"Scuba diving", @"Surfing", @"Tennis", @"Yoga", nil];
    
    [[FindyAPI instance] getAllCraze:self withSelector:@selector(getAllCraze:) andOptions:nil];
}

- (void)getAllCraze:(NSMutableDictionary *)response {
    
    if (response == nil) {
        popularArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"ALL_ACTIVITIES"]];

        [popularArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
        
        for (NSString *interest in popularArray) {
            if ([[DataManager sharedManager].interestArray containsObject:interest]) {
                [interestArray addObject:interest];
            }
        }
    } else {
        popularArray = [[NSMutableArray alloc] initWithArray:[[response objectForKey:@"Parents"] objectForKey:@"Activities"]];
        [popularArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
        
        [[NSUserDefaults standardUserDefaults] setObject:popularArray forKey:@"ALL_ACTIVITIES"];
        
        if (![[DataManager sharedManager].interestArray count]) {
            [DataManager sharedManager].interestArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"INTEREST_ARRAY"]];
        }
        for (NSString *interest in popularArray) {
            if ([[DataManager sharedManager].interestArray containsObject:interest]) {
                [interestArray addObject:interest];
            }
        }
    }
    
    [self initTable];
}

- (void)initTable {
    
//    for (int i = 0; i < [ppArray count]; i++) {
//        NSString *popular = [ppArray objectAtIndex:i];
//        if ([popularArray containsObject:popular]) {
//            [popularArray removeObject:popular];
//        }
//        if ([interestArray containsObject:popularArray]) {
//            [ppArray removeObject:popular];
//            i--;
//        }
//    }
    
    if (sectionArray != nil) {
        [sectionArray removeAllObjects];
        [sectionArray release];
        sectionArray = nil;
    }
    
    if (ppArray != nil) {
        [ppArray removeAllObjects];
        [ppArray addObjectsFromArray:fArray];
    }
    
    [popularArray removeObjectsInArray:interestArray];
    [ppArray removeObjectsInArray:interestArray];
    
    sectionArray = [[NSMutableArray alloc] init];
    [interestArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [ppArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
    for (int i = 0; i < [popularArray count]; i++) {
        NSString *interest = [popularArray objectAtIndex:i];
        if ((![interestArray containsObject:interest]) && (![ppArray containsObject:interest])) {
            
            NSString *fChar = [interest substringToIndex:1];
            
            if (![sectionArray containsObject:fChar]) {
                [sectionArray addObject:[fChar uppercaseString]];
            }
            
        }
    }
    
    [self configureArray:popularArray];
   
    [_interestTable reloadData];
}

- (void)configureArray:(NSMutableArray *)array {
    NSInteger index, sectionTitlesCount = [sectionArray count];
    
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
	// Set up the sections array: elements are mutable arrays that will contain the time zones for that section.
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
	}
    
    [popularArray removeObjectsInArray:interestArray];
    [ppArray removeObjectsInArray:interestArray];
    
    for (NSString *section in array) {
        if ((![interestArray containsObject:section]) && (![ppArray containsObject:section])) {
            NSString *fChar = [section substringToIndex:1];
            
            NSInteger sectionNumber = [sectionArray indexOfObject:fChar];
            
            NSMutableArray *sectionTimeZones = newSectionsArray[sectionNumber];
            
            [sectionTimeZones addObject:section];
        }
	}
    
    for (index = 0; index < sectionTitlesCount; index++) {
        
		NSMutableArray *sArray = newSectionsArray[index];
        if ([sArray count] == 0) {
            [newSectionsArray removeObjectAtIndex:index];
            sectionTitlesCount --;
            index --;
        } else {
            [sArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
            
            // Replace the existing array with the sorted array.
            newSectionsArray[index] = sArray;
        }
	}
    
//    sectionArray = newSectionsArray;
    if ([interestArray count]) {
        sectionArray = [[NSMutableArray alloc] initWithArray:[[[NSMutableArray arrayWithObject:interestArray] arrayByAddingObject:ppArray] arrayByAddingObjectsFromArray:newSectionsArray]];
    } else if ([ppArray count]) {
        sectionArray = [[NSMutableArray alloc] initWithArray:[[NSMutableArray arrayWithObject:ppArray] arrayByAddingObjectsFromArray:newSectionsArray]];
    } else {
        sectionArray = [[NSMutableArray alloc] initWithArray:newSectionsArray];
    }
    
}

- (int)inCurrentInterest:(NSString *)interest {
    for (int i = 0; i < [[DataManager sharedManager].interestArray count]; i++) {
        NSString *inter = [[DataManager sharedManager].interestArray objectAtIndex:i];
        if ([inter isEqualToString:interest]) {
            return i;
        }
    }
    
    return -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonPressed:(id)sender {
    if ([interestArray count]) {
        
        removeCraze = [[NSMutableArray alloc] initWithArray:[DataManager sharedManager].interestArray];
        [removeCraze removeObjectsInArray:interestArray];
        
        NSMutableArray *addArray = [[NSMutableArray alloc] initWithArray:interestArray];
        [addArray removeObjectsInArray:[DataManager sharedManager].interestArray];
        
        [[DataManager sharedManager].interestArray removeAllObjects];
        for (NSString *strInterest in interestArray) {
            [[DataManager sharedManager].interestArray addObject:strInterest];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"INTEREST_UPDATE"];
        
        NSMutableDictionary *authenticationCredentails =
        [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, [addArray componentsJoinedByString:@","],nil]
                                           forKeys:[NSArray arrayWithObjects:@"email", @"craze", nil]];
        
        [[FindyAPI instance] addCraze:self
                         withSelector:@selector(addCrazeResult:)
                           andOptions:authenticationCredentails];
    } else {
        
    }
}

- (void)addCrazeResult:(NSDictionary *)response {
    if ([removeCraze count]) {
        NSMutableDictionary *authenticationCredentails =
        [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, [removeCraze componentsJoinedByString:@","],nil]
                                           forKeys:[NSArray arrayWithObjects:@"email", @"craze", nil]];
        
        [[FindyAPI instance] removeCraze:self
                         withSelector:@selector(removeCrazeResult:)
                           andOptions:authenticationCredentails];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)removeCrazeResult:(NSDictionary *)response {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[sectionArray objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSArray *sArray = [sectionArray objectAtIndex:section];
        if ([sArray count]) {
            NSString *str = [[[sArray objectAtIndex:0] substringToIndex:1] uppercaseString];
            return str;
        } else {
            return nil;
        }
    } else {
        if (section == 0) {
            if ([interestArray count]) {
                return @"MY ACTIVITIES";
            } else {
                if ([ppArray count]) {
                    return @"POPULAR";
                } else {
                    NSArray *sArray = [sectionArray objectAtIndex:section];
                    if ([sArray count]) {
                        NSString *str = [[[sArray objectAtIndex:0] substringToIndex:1] uppercaseString];
                        return str;
                    } else {
                        return nil;
                    }
                }
            }
        } else if (section == 1) {
            if ([interestArray count]) {
                if ([ppArray count]) {
                    return @"POPULAR";
                } else {
                    NSArray *sArray = [sectionArray objectAtIndex:section];
                    if ([sArray count]) {
                        NSString *str = [[[sArray objectAtIndex:0] substringToIndex:1] uppercaseString];
                        return str;
                    } else {
                        return nil;
                    }
                }
            } else {
            
                NSArray *sArray = [sectionArray objectAtIndex:section];
                if ([sArray count]) {
                    NSString *str = [[[sArray objectAtIndex:0] substringToIndex:1] uppercaseString];
                    return str;
                } else {
                    return nil;
                }
            }
        } else {
            NSArray *sArray = [sectionArray objectAtIndex:section];
            if ([sArray count]) {
                NSString *str = [[[sArray objectAtIndex:0] substringToIndex:1] uppercaseString];
                return str;
            } else {
                return nil;
            }
        }
    }

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"InterestCell";
    
    UITableViewCell *cell = nil;
	cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.f]];
 
    cell.textLabel.text = [[sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        if ((![[NSUserDefaults standardUserDefaults] boolForKey:@"ShoutOut"]) && (indexPath.section == 0) && ([interestArray count] != 0)) {
            [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonSelect.png"]];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonDeselect.png"]];
        }
    }
    
    //    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShoutOut"]) {
//        
//    } else {
//        if ([[selectedArray objectAtIndex:indexPath.row] boolValue]) {
//            [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonSelect.png"]];
//        } else {
//            [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonDeselect.png"]];
//        }
//    }
    
    return cell;
}

- (BOOL)checkInterestCount {
    if ([interestArray count] >= 10) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You can select only 10 activities" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        return true;
    }
    
    return false;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShoutOut"]) {
        [DataManager sharedManager].strShoutout = [popularArray objectAtIndex:indexPath.row];
        [[DataManager sharedManager].interestArray addObject:[popularArray objectAtIndex:indexPath.row]];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            if (![self checkInterestCount]) {
                [interestArray addObject:[[[sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] retain]];
                
                [self.searchDisplayController setActive:NO animated:YES];
                [tableView setScrollsToTop:YES];
            }
        } else {
            if ((indexPath.section == 0) && ([interestArray count] != 0)) {
                if ([interestArray count] == 1) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select at least one activity" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                    [alert show];
//                    [alert release];
                } else {
                    [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonDeselect.png"]];
                    NSString *interest = [[sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    
                    if ([fArray containsObject:interest]) {
                        [ppArray addObject:[interest retain]];
                    } else {
                        [popularArray addObject:[interest retain]];
                    }
                    
                    int nIndex = [interestArray indexOfObject:interest];
                    [interestArray removeObjectAtIndex:nIndex];
                }
            } else {
                if (![self checkInterestCount]) {
                    [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonSelect.png"]];
                    [interestArray addObject:[[[sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] retain]];
                }
            }
        }
        
        [self initTable];
//        if ([[selectedArray objectAtIndex:indexPath.row] boolValue]) {
//            [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonDeselect.png"]];
//            [selectedArray setObject:@"0" atIndexedSubscript:indexPath.row];
//            
//        } else {
//            [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonSelect.png"]];
//            [selectedArray setObject:@"1" atIndexedSubscript:indexPath.row];
//        }
    }
}

#pragma mark - UISearchDisplayController delegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    searchActivity = [[NSString alloc] initWithString:searchString];
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
//    if ([searchResults count] == 0) {
//        [suggestView setHidden:YES];
//    }
    
    [self initTable];
}

- (void)dealloc {
    [_interestTable release];
    [popularArray release];
    [selectedArray release];
    [suggestView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [suggestView release];
    suggestView = nil;
    [super viewDidUnload];
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    if ([searchText isEqualToString:@""]) {
        [suggestView setHidden:YES];
        return;
    }
    
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    if (searchResults != nil) {
        [searchResults removeAllObjects];
        [searchResults release];
    }

//    [popularArray addObjectsFromArray:interestArray];
    [ppArray  removeObjectsInArray:popularArray];
    
    [popularArray addObjectsFromArray:ppArray];
    searchResults = [[NSMutableArray alloc] initWithArray:[popularArray filteredArrayUsingPredicate:resultPredicate]];
    
    [ppArray removeObjectsInArray:searchResults];
    
    if ([searchResults count] == 0) {
        [suggestView setHidden:NO];
        [self.view bringSubviewToFront:suggestView];
    } else {
        [suggestView setHidden:YES];
    }
    
    if (sectionArray != nil) {
        [sectionArray removeAllObjects];
        [sectionArray release];
        sectionArray = nil;
    }
    
    sectionArray = [[NSMutableArray alloc] init];
    [interestArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [searchResults sortUsingSelector:@selector(caseInsensitiveCompare:)];
    for (int i = 0; i < [searchResults count]; i++) {
        NSString *interest = [searchResults objectAtIndex:i];
        
        NSString *fChar = [interest substringToIndex:1];
        
        if (![sectionArray containsObject:fChar]) {
            [sectionArray addObject:[fChar uppercaseString]];
        }
    }
    

    [self configureSearchResult:searchResults];
}

- (void)configureSearchResult:(NSArray *)array {
    NSInteger index, sectionTitlesCount = [sectionArray count];
    
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
	// Set up the sections array: elements are mutable arrays that will contain the time zones for that section.
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
	}
    
    [popularArray removeObjectsInArray:interestArray];
    [ppArray removeObjectsInArray:interestArray];
    
    for (NSString *section in array) {
        if (![interestArray containsObject:section]) {
            NSString *fChar = [section substringToIndex:1];
            
            NSInteger sectionNumber = [sectionArray indexOfObject:fChar];
            
            NSMutableArray *sectionTimeZones = newSectionsArray[sectionNumber];
            
            [sectionTimeZones addObject:section];
        }
	}
    
    NSLog(@"%@", newSectionsArray);
    
    for (index = 0; index < sectionTitlesCount; index++) {
        
		NSMutableArray *sArray = newSectionsArray[index];
        if ([sArray count] == 0) {
            [newSectionsArray removeObjectAtIndex:index];
            sectionTitlesCount --;
            index --;
        } else {
            [sArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
            
            // Replace the existing array with the sorted array.
            newSectionsArray[index] = sArray;
        }
	}
    
    sectionArray = [[NSMutableArray alloc] initWithArray:newSectionsArray];
}

- (IBAction)suggestActivity:(id)sender {
    UIAlertView *inputActivity = [[UIAlertView alloc] init];
    [inputActivity setAlertViewStyle:UIAlertViewStylePlainTextInput];
	[inputActivity setDelegate:self];
	[inputActivity setTitle:@"Suggest Activity"];
	[inputActivity addButtonWithTitle:@"Cancel"];
	[inputActivity addButtonWithTitle:@"Suggest"];
    [inputActivity textFieldAtIndex:0].text = searchActivity;
    [inputActivity show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObject:[alertView textFieldAtIndex:0].text forKey:@"craze"];
        [[FindyAPI instance] suggestActivity:self withSelector:@selector(suggestResult:) andOptions:paramDict];
    }
}

- (void)suggestResult:(NSDictionary *)response {
    NSLog(@"%@", response);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) aSearchBar {
    //	[aSearchBar resignFirstResponder];
    [self.searchDisplayController setActive:NO animated:YES];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    //if we only try and resignFirstResponder on textField or searchBar,
    //the keyboard will not dissapear (at least not on iPad)!
    [self performSelector:@selector(searchBarCancelButtonClicked:) withObject:self.searchDisplayController.searchBar afterDelay: 0.1];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // The user clicked the [X] button or otherwise cleared the text.
    if ([searchText isEqualToString:@""]) {
//        [suggestView setHidden:YES];
        [self performSelector:@selector(searchBarCancelButtonClicked:) withObject:searchBar afterDelay:0.1f];
    }
}

@end
