//
//  SoundEffect.swift
//
//  Created by Ben Gottlieb on 3/16/19.
//

#if os(iOS) || os(macOS) || os(watchOS)
import Foundation
import AVFoundation

#if os(OSX)
	import AppKit
	import OpenAL
	import AudioToolbox
#elseif os(iOS)
	import UIKit
	import OpenAL
	import AudioToolbox
#elseif os(watchOS)
	import UIKit
#endif


public class SoundEffect: Equatable {
	private static var cachedSounds: [String: SoundEffect] = [:]
	private static var playingSounds: [SoundEffect] = []
	private static var hasMadeAmbient = false
	public static var hasActivated = false
	public static var disableAllSounds = Gestalt.isOnSimulator
	var internalPlayer: AVAudioPlayer!
	var original: SoundEffect?
	weak var dequeueTimer: Timer?
	public var isPlaying = false
	public private(set) var isLooping = false
	var startedAt: Date?
	var url: URL?
	var data: Data?
	var pausedAt: Date?
	var completion: (() -> Void)?
	public var volume: Float = 1.0 { didSet {
		self.actualPlayer?.volume = volume
	}}
	
	init(original: SoundEffect) {
		self.original = original
	}
	
	func setupPlayer() -> AVAudioPlayer? {
		if internalPlayer == nil {
			do {
				if let url = self.url {
					internalPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: nil)
				} else if let data = self.data {
					internalPlayer = try AVAudioPlayer(data: data, fileTypeHint: nil)
				}
			} catch {
				if let url = self.url {
					logg(error: error, "Problem loading \(url.lastPathComponent)")
				} else {
					logg(error: error, "Problem loading sound")
				}
			}
		}
		return internalPlayer
	}
	
	public init?(url: URL, preload: Bool = true, uncached: Bool = false, ambient: Bool = true) {
		if ambient { SoundEffect.makeAmbient() }
		if let original = SoundEffect.cachedSounds[url.absoluteString] {
			self.original = original
		} else {
			self.url = url
			if preload { self.preload() }
			if !uncached { SoundEffect.cachedSounds[url.absoluteString] = self }
		}
	}
	
	public init?(data: Data?, preload: Bool = true, uncached: Bool = false) {
		SoundEffect.makeAmbient()
		guard let data = data else { return nil }
		
		self.data = data
		if preload { self.preload() }
	}
	
	public func preload() {
		actualPlayer?.prepareToPlay()
	}
	
	public static func activateSession() {
		if self.hasActivated { return }
		self.hasActivated = true
		#if os(iOS) || os(watchOS)
			print("Activating AVAudioSession")
			try? AVAudioSession.sharedInstance().setActive(true)
		#endif
	}
	
	static func makeAmbient() {
		if #available(iOS 10.0, iOSApplicationExtension 10.0, *) {
			if !SoundEffect.hasMadeAmbient {
				SoundEffect.hasMadeAmbient = true
				#if os(iOS) || os(watchOS)
					print("Making sound effects ambient, setting up AVAudioSession")
					try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
					try? AVAudioSession.sharedInstance().setActive(true)
				#endif
			}
		}
	}
	
	@available(iOS 9.0, iOSApplicationExtension 9.0, OSX 10.11, *)
	convenience public init?(named name: String, in bundle: Bundle? = nil, preload: Bool = true, uncached: Bool = false, ambient: Bool = true) {
		if ambient { SoundEffect.makeAmbient() }
		if let existing = SoundEffect.cachedSounds[name] {
			self.init(original: existing)
		} else {
			if let data = NSDataAsset(name: name, bundle: bundle ?? Bundle.main)?.data {
				self.init(data: data, preload: preload, uncached: uncached)
			} else if let url = Bundle.main.url(forResource: name, withExtension: nil) {
				self.init(url: url, preload: preload, uncached: uncached)
				if !uncached { SoundEffect.cachedSounds[name] = self }
			} else if let data = NSDataAsset(name: name, bundle: bundle ?? Bundle.main)?.data {
				self.init(data: data, preload: preload, uncached: uncached)
				if !uncached { SoundEffect.cachedSounds[name] = self }
			} else {
				logg(error: nil, "Unable to locate a sound named \(name) in \(bundle?.description ?? "--")")
				self.init(data: nil, preload: false, uncached: false)
				return nil
			}
		}
	}
	
	public func loop(fadingInOver fadeIn: TimeInterval = 0) {
		actualPlayer?.numberOfLoops = -1
		if self.isLooping { return }
		
		self.isLooping = true
		if self.isPlaying { return }
		self.play(fadingInOver: fadeIn)
	}
	
	public func stop(fadingOutOver fadeOut: TimeInterval = 0) {
		if #available(iOS 10.0, iOSApplicationExtension 10.0, OSX 10.12, OSXApplicationExtension 10.12, *), fadeOut > 0 {
			actualPlayer?.setVolume(0, fadeDuration: fadeOut)
			DispatchQueue.main.asyncAfter(deadline: .now() + fadeOut) {
				self.stop()
			}
			return
		}

		actualPlayer?.numberOfLoops = 0
		self.isLooping = false
		actualPlayer?.stop()
		self.stopPlaying()
	}

	func registerAsPlayingFor(duration: TimeInterval? = nil) {
		if !SoundEffect.playingSounds.contains(self) { SoundEffect.playingSounds.append(self) }
		self.dequeueTimer?.invalidate()
		if let dur = duration {
			self.dequeueTimer = Timer.scheduledTimer(timeInterval: dur * 1.001, target: self, selector: #selector(finishPlaying), userInfo: nil, repeats: false)
		}
	}
	
	func stopPlaying() {
		_ = SoundEffect.playingSounds.remove(self)
		self.isPlaying = false
		self.pausedAt = nil
		self.startedAt = nil
		self.dequeueTimer?.invalidate()
	}
	
	@objc func finishPlaying() {
		self.stopPlaying()
		self.completion?()
		self.completion = nil
	}
	
	public static func ==(lhs: SoundEffect, rhs: SoundEffect) -> Bool {
		return lhs === rhs
	}
}

extension SoundEffect {
	public var duration: TimeInterval? { return actualPlayer?.duration }
	var actualPlayer: AVAudioPlayer? { return self.original?.internalPlayer ?? self.setupPlayer() }
	@discardableResult public func play(fadingInOver fadeIn: TimeInterval = 0, completion: (() -> Void)? = nil) -> Bool {
		guard !SoundEffect.disableAllSounds else {
			print("Sound effects disabled, not playing \(url?.lastPathComponent ?? "sound")")
			completion?()
			return false
		}
		guard let player = actualPlayer else {
			completion?()
			return false
		}
		
		Self.activateSession()
		
		self.completion = completion
		if let startedAt = self.startedAt, let pausedAt = self.pausedAt {
			let elapsed = pausedAt.timeIntervalSince(startedAt)
			self.registerAsPlayingFor(duration: player.duration - elapsed)
		} else {
			self.pausedAt = nil
			self.startedAt = Date()
			self.isPlaying = true
			self.registerAsPlayingFor(duration: player.duration)
		}

		if fadeIn > 0 { player.volume = 0 }
		if !player.play() { return false }

		if #available(iOS 10.0, iOSApplicationExtension 10.0, OSX 10.12, OSXApplicationExtension 10.12, *), fadeIn > 0 {
			player.setVolume(self.volume, fadeDuration: fadeIn)
		}
		return true
	}
	
	public func pause() {
		self.isPlaying = true
		actualPlayer?.pause()
		self.pausedAt = Date()
		self.dequeueTimer?.invalidate()
	}
}
#endif
