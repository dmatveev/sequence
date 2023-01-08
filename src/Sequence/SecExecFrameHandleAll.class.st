Class {
	#name : #SecExecFrameHandleAll,
	#superclass : #SeqExecFramePolicy,
	#category : #Sequence
}

{ #category : #testing }
SecExecFrameHandleAll >> handleStart: blockStream exec: aSeqExecutor pending: pendingFrames [
	"Just take next frame to process and proceed"

	blockStream updateFrame: pendingFrames first.
	pendingFrames removeFirst.
	aSeqExecutor registerStarted: sequence at: blockStream currentTime
]
