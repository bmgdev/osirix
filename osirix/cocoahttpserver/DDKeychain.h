#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface DDKeychain : NSObject
{
	
}

+ (NSString *)passwordForHTTPServer;
+ (BOOL)setPasswordForHTTPServer:(NSString *)password;

+ (void)createNewIdentity;
+ (NSArray *)SSLIdentityAndCertificates;

+ (NSString *)applicationTemporaryDirectory;
+ (NSString *)stringForSecExternalFormat:(SecExternalFormat)extFormat;
+ (NSString *)stringForSecExternalItemType:(SecExternalItemType)itemType;
+ (NSString *)stringForSecKeychainAttrType:(SecKeychainAttrType)attrType;
+ (NSString *)stringForError:(OSStatus)status;

+ (NSArray *)KeychainAccessIdentityList;
+ (SecIdentityRef)KeychainAccessPreferredIdentityForName:(NSString*)name keyUse:(int)keyUse;
+ (void)KeychainAccessSetPreferredIdentity:(SecIdentityRef)identity forName:(NSString*)name keyUse:(int)keyUse;
+ (NSString*)KeychainAccessCertificateCommonNameForIdentity:(SecIdentityRef)identity;
+ (void)KeychainAccessExportCertificateForIdentity:(SecIdentityRef)identity toPath:(NSString*)path;
+ (void)KeychainAccessExportPrivateKeyForIdentity:(SecIdentityRef)identity toPath:(NSString*)path cryptWithPassword:(NSString*)password;

+ (SecIdentityRef)DICOMTLSIdentity;
+ (NSString*)DICOMTLSCertificateName;
+ (void)DICOMTLSGenerateCertificateAndKeyForDCMTK;

@end