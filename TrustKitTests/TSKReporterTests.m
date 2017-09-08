/*
 
 TSKReporterTests.m
 TrustKit
 
 Copyright 2015 The TrustKit Project Authors
 Licensed under the MIT license, see associated LICENSE file for terms.
 See AUTHORS file for the list of project authors.
 
 */

#import <XCTest/XCTest.h>

#import "../TrustKit/TrustKit.h"
#import "../TrustKit/TSKTrustKitConfig.h"

#import "../TrustKit/TSKPinningValidatorResult.h"
#import "../TrustKit/TSKPinningValidator_Private.h"
#import "../TrustKit/Reporting/TSKBackgroundReporter.h"
#import "../TrustKit/Reporting/TSKPinFailureReport.h"
#import "../TrustKit/Reporting/reporting_utils.h"

#import <OCMock/OCMock.h>
#import "../TrustKit/Reporting/vendor_identifier.h"
#import "TSKCertificateUtils.h"

#pragma mark Test suite

@interface TrustKit (TestSupport)
@property (nonatomic, readonly, nullable) NSDictionary *configuration;

- (void)sendValidationReport:(TSKPinningValidatorResult *)result notedHostname:(NSString *)notedHostname pinningPolicy:(NSDictionary<TSKDomainConfigurationKey, id> *)notedHostnamePinningPolicy;
@end


static NSString * const kTSKDefaultReportUri = @"https://overmind.datatheorem.com/trustkit/report";


@interface TSKReporterTests : XCTestCase

@end

@implementation TSKReporterTests
{
    TrustKit *_trustKit;
    //TSKPinFailureReport *_testReporter;
    SecTrustRef _testTrust;
    SecCertificateRef _rootCertificate;
    SecCertificateRef _intermediateCertificate;
    SecCertificateRef _leafCertificate;
    NSArray<NSString *> *_testCertificateChain;
}


- (void)setUp {
    [super setUp];
    
    _rootCertificate = [TSKCertificateUtils createCertificateFromDer:@"GoodRootCA"];
    _intermediateCertificate = [TSKCertificateUtils createCertificateFromDer:@"GoodIntermediateCA"];
    _leafCertificate = [TSKCertificateUtils createCertificateFromDer:@"www.good.com"];
    
    SecCertificateRef certChainArray[2] = { _leafCertificate, _intermediateCertificate };
    SecCertificateRef trustStoreArray[1] = { _rootCertificate };
    
    _testTrust = [TSKCertificateUtils createTrustWithCertificates:(const void **)certChainArray
                                                      arrayLength:sizeof(certChainArray)/sizeof(certChainArray[0])
                                               anchorCertificates:(const void **)trustStoreArray
                                                      arrayLength:sizeof(trustStoreArray)/sizeof(trustStoreArray[0])];
    _testCertificateChain = convertTrustToPemArray(_testTrust);
}

- (void)tearDown
{
    CFRelease(_rootCertificate);
    CFRelease(_intermediateCertificate);
    CFRelease(_leafCertificate);
    CFRelease(_testTrust);
    _trustKit = nil;
    //_testReporter = nil;
    
    [super tearDown];
}

- (void)testIdentifierForVendor
{
    NSString *idfv = identifier_for_vendor();
    XCTAssertNotNil(idfv);
}

@end
