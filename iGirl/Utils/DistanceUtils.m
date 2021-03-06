//
//  DistanceUtils.m
//  Three Hundred
//
//  Created by 郭雪 on 11-8-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DistanceUtils.h"


@implementation DistanceUtils

// returns distance in miles, uses haversine formula
+ (float)distance:(CLLocationCoordinate2D)first second:(CLLocationCoordinate2D)second
{
    float lat1 = [DistanceUtils toRadians:first.latitude];
    float lon1 = [DistanceUtils toRadians:first.longitude];
    float lat2 = [DistanceUtils toRadians:second.latitude];
    float lon2 = [DistanceUtils toRadians:second.longitude];
    float dlat = lat2 - lat1;
    float dlon = lon2 - lon1;
    
    float a = pow(sin(dlat / 2),2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);
    float c = 2 * asin(fmin(1, sqrt(a)));
    float distance = kEarthRadiusInMiles * c; //radius of earth in miles
    
    return distance;
}

+ (int)distanceInMeters:(CLLocationCoordinate2D)first second:(CLLocationCoordinate2D)second
{
    float lat1 = [DistanceUtils toRadians:first.latitude];
    float lon1 = [DistanceUtils toRadians:first.longitude];
    float lat2 = [DistanceUtils toRadians:second.latitude];
    float lon2 = [DistanceUtils toRadians:second.longitude];
    float dlat = lat2 - lat1;
    float dlon = lon2 - lon1;
    
    float a = pow(sin(dlat / 2),2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);
    float c = 2 * asin(fmin(1, sqrt(a)));
    float distance = kEarthRadiusInMeters * c; 
    return (int)round(distance);
}


+ (float)calculatePaddingMaxCoord:(CLLocationCoordinate2D)maxCoord minCoord:(CLLocationCoordinate2D)minCoord vertical:(BOOL)vertical
{
    int distance = [DistanceUtils distanceInMeters:maxCoord second:minCoord];
    int degrees;
    
    if( vertical )
        degrees = 0;
    else
        degrees = 90;
    
    int padBy = distance / 4;
    CLLocationCoordinate2D topCoord = [DistanceUtils inverseFromCoordinate:maxCoord meters:padBy degrees:degrees];
    
    float padding;
    if( vertical)
        padding = fabs(topCoord.latitude) - fabs(maxCoord.latitude);
    else
        padding = fabs(topCoord.longitude) - fabs(maxCoord.longitude);
    
    return fabs(padding);
}

+ (float)toRadians:(float)degrees
{
    return degrees * (M_PI / 180);
}

+ (float) toDegrees:(float)radians
{
    return radians * (180 / M_PI);
}

+ (int) getBearingFromCoordinate:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate
{
    double lat1 = [self toRadians:fromCoordinate.latitude];
    double lon1 = [self toRadians:fromCoordinate.longitude];
    double lat2 = [self toRadians:toCoordinate.latitude];
    double lon2 = [self toRadians:toCoordinate.longitude];
    //double dlat = lat2 - lat1; //unused
    double dlon = lon2 - lon1;
    
    double y = sin(dlon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlon);
    double bearing = atan2(y, x);
    double degrees = [DistanceUtils toDegrees:bearing];
    return ((int)degrees + 360) % 360;
}

+ (NSString*) getBearingNameFromDegrees:(double)degrees
{
    if( degrees > 337 || degrees <= 22 )
    {
        return NSLocalizedString(@"北", @"");
    } else if( degrees > 22 && degrees <= 67 )
    {
        return NSLocalizedString(@"东北", @"");
    } else if( degrees > 67 && degrees <=112 )
    {
        return NSLocalizedString(@"东", @"");
    } else if( degrees > 112 && degrees <= 157 )
    {
        return NSLocalizedString(@"东南", @"");
    } else if( degrees > 157 && degrees <= 202 )
    {
        return NSLocalizedString(@"南", @"");
    } else if( degrees > 202 && degrees <= 247 )
    {
        return NSLocalizedString(@"西南", @"");
    } else if( degrees > 247 && degrees <= 292 )
    {
        return NSLocalizedString(@"西", @"");
    } else if( degrees > 292 && degrees <= 337 )
    {
        return NSLocalizedString(@"西北", @"");;
    }
    return NSLocalizedString(@"未知", @"");;
}

+ (CLLocationCoordinate2D) inverseFromCoordinate:(CLLocationCoordinate2D)coordinate miles:(NSInteger)miles degrees:(NSInteger)degrees
{
    int meters = (int)[DistanceUtils milesToMeters:miles];
    return [DistanceUtils inverseFromCoordinate:coordinate meters:meters degrees:degrees];
}

+ (CLLocationCoordinate2D) inverseFromCoordinate:(CLLocationCoordinate2D)coordinate meters:(int)meters degrees:(NSInteger)degrees
{
    float calcMeters = (float)meters;
    float metersPerDegree = 111120.00071117;
    float degreesPerMeter = 1.0 / metersPerDegree;
    float radiansPerDegree = M_PI / 180.0;
    float degreesPerRadian = 180.0 / M_PI;
    
    if( calcMeters > metersPerDegree*180 )
    {
        degrees -= 180.0;
        if( degrees < 0.0 )
            degrees += 360.0;
        calcMeters = metersPerDegree * 360.0 - calcMeters;
    }
    
    if (degrees > 180.0)
        degrees -= 360.0;
    
    float c = degrees * radiansPerDegree;
    float d = calcMeters * degreesPerMeter * radiansPerDegree;
    float L1 = coordinate.latitude * radiansPerDegree;
    float lon = coordinate.longitude * radiansPerDegree;
    float coL1 = (90.0 - coordinate.latitude) * radiansPerDegree;
    float coL2 = [DistanceUtils ahav:[DistanceUtils hav:c] / ([DistanceUtils sec:L1] * [DistanceUtils csc:d]) + [DistanceUtils hav:(d - coL1)]];
    float L2   = (M_PI / 2) - coL2;
    float l = L2 - L1;
    
    float dLo = cos(L1) * cos(L2);
    if (dLo != 0)
        dLo  = [DistanceUtils ahav:(  ([DistanceUtils hav:d] - [DistanceUtils hav:l]) / dLo)];
    
    if (c < 0)
        dLo = -dLo;
    
    lon += dLo;
    if (lon < -M_PI)
        lon += 2 * M_PI;
    else if(lon > M_PI)
        lon -= 2 * M_PI;
    
    float xlat = L2 * degreesPerRadian;
    float xlon = lon * degreesPerRadian;
    
    CLLocationCoordinate2D returnCoord;
    returnCoord.latitude = xlat;
    returnCoord.longitude = xlon;
    
    return returnCoord;
}

+ (int)milesToMeters:(float)miles
{
    return (int)(miles * 1609.344);
}

+ (float)metersToMiles:(int)meters
{
    return (float)meters * 0.0006213;    
}

+ (float)ngt1:(float)x
{
    float result;
    if( fabs(x) > 1)
        result = copysign(1.0, x);
    else
        result = x;
    return result;        
}

+ (float)hav:(float)x
{
    return (1 - cos(x)) * 0.5;
}

+ (float)ahav:(float)x
{
    return acos([DistanceUtils ngt1:(1 - (x * 2))]);
}

+ (float)sec:(float)x
{
    return 1 / cos(x);
}

+ (float)csc:(float)x
{
    return 1 / sin(x);
}

+ (NSString *)getDistanceString:(double)lon 
                            lat:(double)lat 
                          mylon:(double)mylon 
                          mylat:(double)mylat
{
    NSString *distance = nil;
    int meters = [DistanceUtils distanceInMeters:CLLocationCoordinate2DMake(mylat, mylon) second:CLLocationCoordinate2DMake(lat, lon)];
    if (meters > 1000 * 100) {
        int kilometers = (int)meters / 1000;
        distance = [NSString stringWithFormat:NSLocalizedString(@"%d公里", @""), kilometers];
    } else if (meters > 1000) {
        float kilometers = (float)meters / 1000.0;
        distance = [NSString stringWithFormat:NSLocalizedString(@"%1.2f公里", @""), kilometers];
    } else {
        distance = [NSString stringWithFormat:NSLocalizedString(@"%d米", @""), meters];
    }
    return distance;
}

@end
