Class {
	#name : #SecExecFrameHandleAll,
	#superclass : #SeqExecFramePolicy,
	#category : #Sequence
}

{ #category : #testing }
SecExecFrameHandleAll >> handleStart: blockStream exec: aSeqExecutor pending: pendingFrames [
	"Just take next frame to process and proceed"
	| frame |
	frame := pendingFrames first.
	blockStream updateFrame: frame.
	pendingFrames removeFirst.
	aSeqExecutor registerStarted: sequence on: frame at: blockStream currentTime
]
