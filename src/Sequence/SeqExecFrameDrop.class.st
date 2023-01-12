Class {
	#name : #SeqExecFrameDrop,
	#superclass : #SeqExecFramePolicy,
	#category : #Sequence
}

{ #category : #testing }
SeqExecFrameDrop >> handleStart: blockStream exec: aSeqExecutor pending: pendingFrames [
	"Implement simple frame-dropping right here, if needed.				
	If there's > 1 frame, mark all but last as dropped already."
	
	pendingFrames asArray allButLastDo: [ :each |
		each markDropped.
		aSeqExecutor registerDropped: sequence ].
	pendingFrames last availableSince = blockStream currentTime
		ifFalse: [
			pendingFrames last markDropped. "Late for this too. Drop & do nothing"
			aSeqExecutor registerDropped: sequence ] 
		ifTrue: [ | frame |
			frame := pendingFrames last.
			blockStream updateFrame: frame.
			aSeqExecutor registerStarted: sequence on: frame at: blockStream currentTime ].
	pendingFrames removeAll
]
