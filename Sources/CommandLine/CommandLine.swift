/*
 *  Copyright (c) 2016 Spotify AB.
 *
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

import Foundation

public typealias Command = String

/// Class acting as a programmatic interface to the macOS command line
/// Ref.: https://github.com/spotify/HubFramework/blob/master/live/sources/CommandLine.swift
public class CommandLine {

    /**
     *  Execute a command on the command line and return the result
     *
     *  - Parameter command: The command to execute
     *  - Parameter arguments: The arguments to pass to the executed command
     *  - Parameter machine: The machine on which the command is executed
     */
    public static func execute(_ command: Command, with arguments: [String], on machine: Machine = .local) -> CommandLineResult {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.launch(on: machine)

        if let errorOuput = output(fromPipe: errorPipe) {
            if errorOuput.characters.count > 0 {
                return .error(errorOuput)
            }
        }

        return .output(output(fromPipe: outputPipe) ?? "")
    }

    private static func output(fromPipe pipe: Pipe) -> String? {
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: outputData, encoding: .utf8)
    }

}
