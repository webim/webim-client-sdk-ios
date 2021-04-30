//
//  MimeType.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 14.10.17.
//  Copyright © 2017 Webim. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

// MARK: - Global constants
fileprivate let DEFAULT_MIME_TYPE = "application/octet-stream"
// swiftlint:disable colon
fileprivate let mimeTypes = [
    "html" : "text/html",
    "htm" : "text/html",
    "shtml" : "text/html",
    "css" : "text/css",
    "xml" : "text/xml",
    "gif" : "image/gif",
    "jpeg" : "image/jpeg",
    "jpg" : "image/jpeg",
    "heic" : "image/heic",
    "heif" : "image/heif",
    "js" : "application/javascript",
    "atom" : "application/atom+xml",
    "rss" : "application/rss+xml",
    "mml" : "text/mathml",
    "txt" : "text/plain",
    "jad" : "text/vnd.sun.j2me.app-descriptor",
    "wml" : "text/vnd.wap.wml",
    "htc" : "text/x-component",
    "png" : "image/png",
    "tif" : "image/tiff",
    "tiff" : "image/tiff",
    "wbmp" : "image/vnd.wap.wbmp",
    "ico" : "image/x-icon",
    "jng" : "image/x-jng",
    "bmp" : "image/x-ms-bmp",
    "svg" : "image/svg+xml",
    "svgz" : "image/svg+xml",
    "webp" : "image/webp",
    "woff" : "application/font-woff",
    "jar" : "application/java-archive",
    "war" : "application/java-archive",
    "ear" : "application/java-archive",
    "json" : "application/json",
    "hqx" : "application/mac-binhex40",
    "doc" : "application/msword",
    "pdf" : "application/pdf",
    "ps" : "application/postscript",
    "eps" : "application/postscript",
    "ai" : "application/postscript",
    "rtf" : "application/rtf",
    "m3u8" : "application/vnd.apple.mpegurl",
    "xls" : "application/vnd.ms-excel",
    "eot" : "application/vnd.ms-fontobject",
    "ppt" : "application/vnd.ms-powerpoint",
    "wmlc" : "application/vnd.wap.wmlc",
    "kml" : "application/vnd.google-earth.kml+xml",
    "kmz" : "application/vnd.google-earth.kmz",
    "7z" : "application/x-7z-compressed",
    "cco" : "application/x-cocoa",
    "jardiff" : "application/x-java-archive-diff",
    "jnlp" : "application/x-java-jnlp-file",
    "run" : "application/x-makeself",
    "pl" : "application/x-perl",
    "pm" : "application/x-perl",
    "prc" : "application/x-pilot",
    "pdb" : "application/x-pilot",
    "rar" : "application/x-rar-compressed",
    "rpm" : "application/x-redhat-package-manager",
    "sea" : "application/x-sea",
    "swf" : "application/x-shockwave-flash",
    "sit" : "application/x-stuffit",
    "tcl" : "application/x-tcl",
    "tk" : "application/x-tcl",
    "der" : "application/x-x509-ca-cert",
    "pem" : "application/x-x509-ca-cert",
    "crt" : "application/x-x509-ca-cert",
    "xpi" : "application/x-xpinstall",
    "xhtml" : "application/xhtml+xml",
    "xspf" : "application/xspf+xml",
    "zip" : "application/zip",
    "bin" : "application/octet-stream",
    "exe" : "application/octet-stream",
    "dll" : "application/octet-stream",
    "deb" : "application/octet-stream",
    "dmg" : "application/octet-stream",
    "iso" : "application/octet-stream",
    "img" : "application/octet-stream",
    "msi" : "application/octet-stream",
    "msp" : "application/octet-stream",
    "msm" : "application/octet-stream",
    "docx" : "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "xlsx" : "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "pptx" : "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "mid" : "audio/midi",
    "midi" : "audio/midi",
    "kar" : "audio/midi",
    "mp3" : "audio/mpeg",
    "ogg" : "audio/ogg",
    "m4a" : "audio/x-m4a",
    "ra" : "audio/x-realaudio",
    "3gpp" : "video/3gpp",
    "3gp" : "video/3gpp",
    "ts" : "video/mp2t",
    "mp4" : "video/mp4",
    "mpeg" : "video/mpeg",
    "mpg" : "video/mpeg",
    "mov" : "video/quicktime",
    "webm" : "video/webm",
    "flv" : "video/x-flv",
    "m4v" : "video/x-m4v",
    "mng" : "video/x-mng",
    "asx" : "video/x-ms-asf",
    "asf" : "video/x-ms-asf",
    "wmv" : "video/x-ms-wmv",
    "avi" : "video/x-msvideo",
    "key" : "application/x-iwork-keynote-sffkey",
    "pages" : "application/x-iwork-pages-sffpages",
    "numbers" : "application/x-iwork-numbers-sffnumbers"
]

// swiftlint:enable colon
// MARK: -
struct MimeType {
    
    // MARK: - Properties
    private let `extension`: String
    var value: String {
        return (mimeTypes[`extension`.lowercased()] ?? DEFAULT_MIME_TYPE)
    }
    
    // MARK: - Initialization
    public init(url: URL) {
        `extension` = url.pathExtension
    }
    
    public init() {
        `extension` = "jpeg"
    }
    
}

// MARK: -
func isImage(contentType: String) -> Bool {
    return ((contentType == "image/gif")
        || (contentType == "image/jpeg")
        || (contentType == "image/png")
        || (contentType == "image/tiff"))
}

// Check if file is acceptable to show in WKWebView
func isAcceptableFile(contentType: String) -> Bool {
    return ((contentType == mimeTypes["txt"])
    || (contentType == mimeTypes["rtf"])
    || (contentType == mimeTypes["pdf"])
    || (contentType == mimeTypes["doc"])
    || (contentType == mimeTypes["docx"])
    || (contentType == mimeTypes["xls"])
    || (contentType == mimeTypes["xlsx"])
    || (contentType == mimeTypes["ppt"])
    || (contentType == mimeTypes["pptx"])
    || (contentType == mimeTypes["mp4"])
    || (contentType == mimeTypes["key"])
    || (contentType == mimeTypes["pages"])
    || (contentType == mimeTypes["numbers"])
        
    || (contentType == "text/rtf"))
}
