/*
 *
 *  Copyright (C) 1994-2005, OFFIS
 *
 *  This software and supporting documentation were developed by
 *
 *    Kuratorium OFFIS e.V.
 *    Healthcare Information and Communication Systems
 *    Escherweg 2
 *    D-26121 Oldenburg, Germany
 *
 *  THIS SOFTWARE IS MADE AVAILABLE,  AS IS,  AND OFFIS MAKES NO  WARRANTY
 *  REGARDING  THE  SOFTWARE,  ITS  PERFORMANCE,  ITS  MERCHANTABILITY  OR
 *  FITNESS FOR ANY PARTICULAR USE, FREEDOM FROM ANY COMPUTER DISEASES  OR
 *  ITS CONFORMITY TO ANY SPECIFICATION. THE ENTIRE RISK AS TO QUALITY AND
 *  PERFORMANCE OF THE SOFTWARE IS WITH THE USER.
 *
 *  Module:  dcmdata
 *
 *  Author:  Gerd Ehlers, Andreas Barth
 *
 *  Purpose: Implementation of class DcmPixelSequence
 *
 *  Last Update:      $Author: lpysher $
 *  Update Date:      $Date: 2006/03/01 20:15:22 $
 *  CVS/RCS Revision: $Revision: 1.1 $
 *  Status:           $State: Exp $
 *
 *  CVS/RCS Log at end of file
 *
 */


#include "osconfig.h"    /* make sure OS specific configuration is included first */

#define INCLUDE_CSTDLIB
#define INCLUDE_CSTDIO
#include "ofstdinc.h"

#include "ofstream.h"
#include "dcpixseq.h"
#include "dcpxitem.h"
#include "dcitem.h"
#include "dcvr.h"
#include "dcdebug.h"

#include "dcdeftag.h"


// ********************************


DcmPixelSequence::DcmPixelSequence(const DcmTag &tag,
                                   const Uint32 len)
  : DcmSequenceOfItems(tag, len),
    Xfer(EXS_Unknown)
{
    Tag.setVR(EVR_OB);
    Length = DCM_UndefinedLength; // pixel sequences always use undefined length
}


DcmPixelSequence::DcmPixelSequence(const DcmPixelSequence &old)
  : DcmSequenceOfItems(old),
    Xfer(old.Xfer)
{
    /* everything gets handled in DcmSequenceOfItems constructor */
}


DcmPixelSequence::~DcmPixelSequence()
{
}


DcmPixelSequence &DcmPixelSequence::operator=(const DcmPixelSequence &obj)
{
    DcmSequenceOfItems::operator=(obj);
    Xfer = obj.Xfer;
    return *this;
}


// ********************************


void DcmPixelSequence::print(ostream &out,
                             const size_t flags,
                             const int level,
                             const char *pixelFileName,
                             size_t *pixelCounter)
{
    /* print pixel sequence start line */
    if (flags & DCMTypes::PF_showTreeStructure)
    {
        /* empty text */
        printInfoLine(out, flags, level);
        /* print pixel sequence content */
        if (!itemList->empty())
        {
            /* reset internal flags */
            const size_t newFlags = flags & ~DCMTypes::PF_lastEntry;
            /* print pixel items */
            DcmObject *dO;
            itemList->seek(ELP_first);
            do {
                dO = itemList->get();
                dO->print(out, newFlags, level + 1, pixelFileName, pixelCounter);
            } while (itemList->seek(ELP_next));
        }
    } else {
        OFOStringStream oss;
        oss << "(PixelSequence ";
        if (Length != DCM_UndefinedLength)
            oss << "with explicit length ";
        oss << "#=" << card() << ")" << OFStringStream_ends;
        OFSTRINGSTREAM_GETSTR(oss, tmpString)
        printInfoLine(out, flags, level, tmpString);
        OFSTRINGSTREAM_FREESTR(tmpString)
        /* print pixel sequence content */
        if (!itemList->empty())
        {
            DcmObject *dO;
            itemList->seek(ELP_first);
            do {
                dO = itemList->get();
                dO->print(out, flags, level + 1, pixelFileName, pixelCounter);
            } while (itemList->seek(ELP_next));
        }
        /* print pixel sequence end line */
        DcmTag delimItemTag(DCM_SequenceDelimitationItem);
        if (Length == DCM_UndefinedLength)
            printInfoLine(out, flags, level, "(SequenceDelimitationItem)", &delimItemTag);
        else
            printInfoLine(out, flags, level, "(SequenceDelimitationItem for re-encod.)", &delimItemTag);
    }
}


// ********************************


Uint32 DcmPixelSequence::calcElementLength(const E_TransferSyntax xfer,
                                           const E_EncodingType enctype)
{
    // add 8 bytes for Sequence Delimitation Tag which always exists for Pixel Sequences
    return DcmElement::calcElementLength(xfer, enctype) + 8;
}


// ********************************


OFCondition DcmPixelSequence::makeSubObject(DcmObject *&subObject,
                                            const DcmTag &newTag,
                                            const Uint32 newLength)
{
    OFCondition l_error = EC_Normal;
    DcmObject *newObject = NULL;

    switch (newTag.getEVR())
    {
        case EVR_na:
            if (newTag.getXTag() == DCM_Item)
                newObject = new DcmPixelItem(newTag, newLength);
            else if (newTag.getXTag() == DCM_SequenceDelimitationItem)
                l_error = EC_SequEnd;
            else if (newTag.getXTag() == DCM_ItemDelimitationItem)
                l_error = EC_ItemEnd;
            else
                l_error = EC_InvalidTag;
            break;

        default:
            newObject = new DcmPixelItem(newTag, newLength);
            l_error = EC_CorruptedData;
            break;
    }

    subObject = newObject;
    return l_error;
}


// ********************************


OFCondition DcmPixelSequence::insert(DcmPixelItem *item,
                                     unsigned int where)
{
    errorFlag = EC_Normal;
    if (item != NULL)
    {
        itemList->seek_to(where);
        itemList->insert(item);
        DCM_dcmdataCDebug(3, where< itemList->card(), ("DcmPixelSequence::insert() item at position %d inserted", where));
        DCM_dcmdataCDebug(3, where>=itemList->card(), ("DcmPixelSequence::insert() item at last position inserted"));
    } else
        errorFlag = EC_IllegalCall;
    return errorFlag;
}


// ********************************


OFCondition DcmPixelSequence::getItem(DcmPixelItem *&item,
                                      const unsigned int num)
{
    errorFlag = EC_Normal;
    item = OFstatic_cast(DcmPixelItem*, itemList->seek_to(num));  // read item from list
    if (item == NULL)
        errorFlag = EC_IllegalCall;
    return errorFlag;
}


// ********************************


OFCondition DcmPixelSequence::remove(DcmPixelItem *&item,
                                     const unsigned int num)
{
    errorFlag = EC_Normal;
    item = OFstatic_cast(DcmPixelItem*, itemList->seek_to(num));  // read item from list
    if (item != NULL)
        itemList->remove();
    else
        errorFlag = EC_IllegalCall;
    return errorFlag;
}


// ********************************


OFCondition DcmPixelSequence::remove(DcmPixelItem *item)
{
    errorFlag = EC_IllegalCall;
    if (!itemList->empty() && item != NULL)
    {
        DcmObject *dO;
        itemList->seek(ELP_first);
        do {
            dO = itemList->get();
            if (dO == item)
            {
                itemList->remove();         // remove element from list, but do no delete it
                errorFlag = EC_Normal;
                break;
            }
        } while (itemList->seek(ELP_next));
    }
    return errorFlag;
}


// ********************************


OFCondition DcmPixelSequence::changeXfer(const E_TransferSyntax newXfer)
{
    if (Xfer == EXS_Unknown || canWriteXfer(newXfer, Xfer))
    {
        Xfer = newXfer;
        return EC_Normal;
    } else
        return EC_IllegalCall;
}


// ********************************


OFBool DcmPixelSequence::canWriteXfer(const E_TransferSyntax newXfer,
                                      const E_TransferSyntax oldXfer)
{
    DcmXfer newXferSyn(newXfer);

    return newXferSyn.isEncapsulated() && newXfer == oldXfer && oldXfer == Xfer;
}


// ********************************


OFCondition DcmPixelSequence::read(DcmInputStream &inStream,
                                   const E_TransferSyntax ixfer,
                                   const E_GrpLenEncoding glenc,
                                   const Uint32 maxReadLength)
{
    OFCondition l_error = changeXfer(ixfer);
    if (l_error.good())
        return DcmSequenceOfItems::read(inStream, ixfer, glenc, maxReadLength);

    return l_error;
}


// ********************************


OFCondition DcmPixelSequence::write(DcmOutputStream &outStream,
                                      const E_TransferSyntax oxfer,
                                      const E_EncodingType /*enctype*/)
{
    OFCondition l_error = changeXfer(oxfer);
    if (l_error.good())
        return DcmSequenceOfItems::write(outStream, oxfer, EET_UndefinedLength);

    return l_error;
}


// ********************************


OFCondition DcmPixelSequence::writeSignatureFormat(DcmOutputStream &outStream,
                                                   const E_TransferSyntax oxfer,
                                                   const E_EncodingType /*enctype*/)
{
    OFCondition l_error = changeXfer(oxfer);
    if (l_error.good())
        return DcmSequenceOfItems::writeSignatureFormat(outStream, oxfer, EET_UndefinedLength);

    return l_error;
}


OFCondition DcmPixelSequence::storeCompressedFrame(DcmOffsetList &offsetList,
                                                   Uint8 *compressedData,
                                                   Uint32 compressedLen,
                                                   Uint32 fragmentSize)
{
    if (compressedData == NULL)
        return EC_IllegalCall;

    OFCondition result = EC_Normal;
    if (fragmentSize >= 0x400000)
        fragmentSize = 0;    // prevent overflow
    else
        fragmentSize <<= 10; // unit is kbytes
    if (fragmentSize == 0)
        fragmentSize = compressedLen;

    Uint32 offset = 0;
    Uint32 currentSize = 0;
    Uint32 numFragments = 0;
    DcmPixelItem *fragment = NULL;

    while ((offset < compressedLen) && (result.good()))
    {
        fragment = new DcmPixelItem(DcmTag(DCM_Item,EVR_OB));
        if (fragment == NULL)
            result = EC_MemoryExhausted;
        else
        {
            insert(fragment);
            numFragments++;
            currentSize = fragmentSize;
            if (offset + currentSize > compressedLen)
                currentSize = compressedLen - offset;
            result = fragment->putUint8Array(compressedData+offset, currentSize);
            if (result.good())
                offset += currentSize;
        }
    }

    currentSize = offset + (numFragments << 3); // 8 bytes extra for each item header
    offsetList.push_back(currentSize);
    return result;
}


/*
** CVS/RCS Log:
** $Log: dcpixseq.cc,v $
** Revision 1.1  2006/03/01 20:15:22  lpysher
** Added dcmtkt ocvs not in xcode  and fixed bug with multiple monitors
**
** Revision 1.36  2005/12/08 15:41:26  meichel
** Changed include path schema for all DCMTK header files
**
** Revision 1.35  2005/11/28 15:53:13  meichel
** Renamed macros in dcdebug.h
**
** Revision 1.34  2005/05/27 09:45:38  meichel
** Fixed bug that caused incorrect sequence and item lengths to be computed for
**   compressed pixel data embedded in a sequence such as the IconImageSequence.
**
** Revision 1.33  2004/02/04 16:41:37  joergr
** Adapted type casts to new-style typecast operators defined in ofcast.h.
** Removed acknowledgements with e-mail addresses from CVS log.
**
** Revision 1.32  2003/03/21 13:08:04  meichel
** Minor code purifications for warnings reported by MSVC in Level 4
**
** Revision 1.31  2003/01/06 09:29:49  joergr
** Performed minor text corrections to get a more consistent print() output.
**
** Revision 1.30  2002/12/06 13:16:58  joergr
** Enhanced "print()" function by re-working the implementation and replacing
** the boolean "showFullData" parameter by a more general integer flag.
** Made source code formatting more consistent with other modules/files.
**
** Revision 1.29  2002/11/27 12:06:50  meichel
** Adapted module dcmdata to use of new header file ofstdinc.h
**
** Revision 1.28  2002/08/27 16:55:55  meichel
** Initial release of new DICOM I/O stream classes that add support for stream
**   compression (deflated little endian explicit VR transfer syntax)
**
** Revision 1.27  2002/05/24 14:51:50  meichel
** Moved helper methods that are useful for different compression techniques
**   from module dcmjpeg to module dcmdata
**
** Revision 1.26  2002/04/16 13:43:19  joergr
** Added configurable support for C++ ANSI standard includes (e.g. streams).
**
** Revision 1.25  2001/09/25 17:19:52  meichel
** Adapted dcmdata to class OFCondition
**
** Revision 1.24  2001/06/01 15:49:07  meichel
** Updated copyright header
**
** Revision 1.23  2000/11/07 16:56:22  meichel
** Initial release of dcmsign module for DICOM Digital Signatures
**
** Revision 1.22  2000/03/08 16:26:39  meichel
** Updated copyright header.
**
** Revision 1.21  2000/03/06 18:13:44  joergr
** Local variable hided member variable (reported by Sun CC 4.2).
**
** Revision 1.20  2000/03/03 15:02:10  joergr
** Corrected bug related to padding of file and item size.
**
** Revision 1.19  2000/02/23 15:11:58  meichel
** Corrected macro for Borland C++ Builder 4 workaround.
**
** Revision 1.18  2000/02/10 10:52:21  joergr
** Added new feature to dcmdump (enhanced print method of dcmdata): write
** pixel data/item value fields to raw files.
**
** Revision 1.17  2000/02/02 14:32:53  joergr
** Replaced 'delete' statements by 'delete[]' for objects created with 'new[]'.
**
** Revision 1.16  2000/02/01 10:12:09  meichel
** Avoiding to include <stdlib.h> as extern "C" on Borland C++ Builder 4,
**   workaround for bug in compiler header files.
**
** Revision 1.15  1999/03/31 09:25:36  meichel
** Updated copyright header in module dcmdata
**
** Revision 1.14  1998/11/12 16:48:18  meichel
** Implemented operator= for all classes derived from DcmObject.
**
** Revision 1.13  1998/07/15 15:52:05  joergr
** Removed several compiler warnings reported by gcc 2.8.1 with
** additional options, e.g. missing copy constructors and assignment
** operators, initialization of member variables in the body of a
** constructor instead of the member initialization list, hiding of
** methods by use of identical names, uninitialized member variables,
** missing const declaration of char pointers. Replaced tabs by spaces.
**
** Revision 1.12  1997/07/21 08:19:33  andreas
** - New environment for encapsulated pixel representations. DcmPixelData
**   can contain different representations and uses codecs to convert
**   between them. Codecs are derived from the DcmCodec class. New error
**   codes are introduced for handling of representations. New internal
**   value representation (only for ident()) for PixelData
** - Replace all boolean types (BOOLEAN, CTNBOOLEAN, DICOM_BOOL, BOOL)
**   with one unique boolean type OFBool.
**
** Revision 1.11  1997/07/07 07:51:36  andreas
** - Changed type for Tag attribute in DcmObject from prointer to value
** - Enhanced (faster) byte swapping routine. swapIfNecessary moved from
**   a method in DcmObject to a general function.
**
** Revision 1.10  1997/07/03 15:10:02  andreas
** - removed debugging functions Bdebug() and Edebug() since
**   they write a static array and are not very useful at all.
**   Cdebug and Vdebug are merged since they have the same semantics.
**   The debugging functions in dcmdata changed their interfaces
**   (see dcmdata/include/dcdebug.h)
**
** Revision 1.9  1997/06/06 09:55:30  andreas
** - corrected error: canWriteXfer returns false if the old transfer syntax
**   was unknown, which causes several applications to prohibit the writing
**   of dataset.
**
** Revision 1.8  1997/05/27 13:49:01  andreas
** - Add method canWriteXfer to class DcmObject and all derived classes.
**   This method checks whether it is possible to convert the original
**   transfer syntax to an new transfer syntax. The check is used in the
**   dcmconv utility to prohibit the change of a compressed transfer
**   syntax to a uncompressed.
**
** Revision 1.7  1997/05/26 15:08:15  andreas
** - Corrected typo in write method
**
** Revision 1.6  1997/05/22 16:57:15  andreas
** - Corrected errors for writing of pixel sequences for encapsulated
**   transfer syntaxes.
**
** Revision 1.5  1996/08/05 08:46:15  andreas
** new print routine with additional parameters:
**         - print into files
**         - fix output length for elements
** corrected error in search routine with parameter ESM_fromStackTop
**
** Revision 1.4  1996/01/29 13:38:29  andreas
** - new put method for every VR to put value as a string
** - better and unique print methods
**
** Revision 1.3  1996/01/05 13:27:40  andreas
** - changed to support new streaming facilities
** - unique read/write methods for file and block transfer
** - more cleanups
**
*/
