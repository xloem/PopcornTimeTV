//
//  ExceptionCatcher.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 25.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation

public struct NSExceptionError: Swift.Error {

   public let exception: NSException

   public init(exception: NSException) {
      self.exception = exception
   }
}

public struct ObjC {

    public static func perform(workItem: @escaping () -> Void) throws {
      let exception = ExecuteWithObjCExceptionHandling {
         workItem()
      }
      if let exception = exception {
         throw NSExceptionError(exception: exception)
      }
   }
}
