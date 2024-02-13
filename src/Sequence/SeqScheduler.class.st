Class {
	#name : #SeqScheduler,
	#superclass : #Object,
	#instVars : [
		'onLockBlock',
		'onReleaseBlock',
		'onAskLockBlock',
		'onAskReleaseBlock'
	],
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqScheduler >> askLockOn: aSeqTarget for: aSeqEventStream at: aTimePoint [ 
	"Say YES in the default implementation"
	onAskLockBlock ifNotNil: [ ^onAskLockBlock cull: aSeqTarget cull: aSeqEventStream cull: aTimePoint ].
	^true
]

{ #category : #'as yet unclassified' }
SeqScheduler >> askReleaseOn: aSeqTarget for: aSeqEventStream at: aTimePoint [ 
	onAskReleaseBlock ifNotNil: [ ^onAskReleaseBlock cull: aSeqTarget cull: aSeqEventStream cull: aTimePoint ].
	^true "Say yes by default"
]

{ #category : #'as yet unclassified' }
SeqScheduler >> decide: aCollectionOfStreams [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SeqScheduler >> informLocked: aSeqTarget for: aSeqEventStream at: aSeqBlock [ 
	onLockBlock ifNotNil: [onLockBlock value: aSeqTarget value: aSeqEventStream]
]

{ #category : #'as yet unclassified' }
SeqScheduler >> informReleased: aSeqTarget for: aSeqEventStream at: aSeqBlock [ 
	onReleaseBlock ifNotNil: [ onReleaseBlock value: aSeqTarget value: aSeqEventStream ]
]

{ #category : #'as yet unclassified' }
SeqScheduler >> onAskLock: aBlock [
	onAskLockBlock := aBlock
]

{ #category : #'as yet unclassified' }
SeqScheduler >> onAskRelease: aBlock [
	onAskReleaseBlock := aBlock
]

{ #category : #'as yet unclassified' }
SeqScheduler >> onLock: aBlock [
	onLockBlock := aBlock
]

{ #category : #'as yet unclassified' }
SeqScheduler >> onRelease: aBlock [
	onReleaseBlock := aBlock
]
