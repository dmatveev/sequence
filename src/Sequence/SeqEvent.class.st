Class {
	#name : #SeqEvent,
	#superclass : #Object,
	#instVars : [
		'startTime',
		'block',
		'frame',
		'lane',
		'duration',
		'readyToStartTime',
		'readyToCompleteTime',
		'releaseTime'
	],
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqEvent class >> on: aTimeD with: aBlock inContextOf: aFrame [
	^self new
		startTime: aTimeD;
		block: aBlock;
		frame: aFrame;
		yourself
]

{ #category : #accessing }
SeqEvent >> block [
	^ block
]

{ #category : #accessing }
SeqEvent >> block: anObject [
	block := anObject
]

{ #category : #modelling }
SeqEvent >> duration [
	^duration
]

{ #category : #accessing }
SeqEvent >> duration: aDuration [
	duration := aDuration
]

{ #category : #modelling }
SeqEvent >> endTime [
	"FIXME: This shoulf be extended with waitCompleteTime..."
	^startTime + self duration
]

{ #category : #accessing }
SeqEvent >> frame [
	^ frame
]

{ #category : #accessing }
SeqEvent >> frame: anObject [
	frame := anObject
]

{ #category : #accessing }
SeqEvent >> lane [
	^ lane
]

{ #category : #accessing }
SeqEvent >> lane: anObject [
	lane := anObject
]

{ #category : #accessing }
SeqEvent >> printOn: aStream [
	startTime printOn: aStream.
	aStream
		nextPutAll: ' - ';
		nextPutAll: block name;
	   nextPutAll: ' #'.
	frame id printOn: aStream.
]

{ #category : #'as yet unclassified' }
SeqEvent >> readyToCompleteTime: aDuration [ 
	readyToCompleteTime := aDuration
]

{ #category : #'as yet unclassified' }
SeqEvent >> readyToStartTime: aDuration [ 
	readyToStartTime := aDuration
]

{ #category : #'as yet unclassified' }
SeqEvent >> releaseTime: aDuration [
	releaseTime := aDuration
]

{ #category : #accessors }
SeqEvent >> seqBlock [
	^block
]

{ #category : #accessing }
SeqEvent >> startTime [
	^ startTime
]

{ #category : #accessing }
SeqEvent >> startTime: anObject [
	startTime := anObject
]

{ #category : #'as yet unclassified' }
SeqEvent >> waitCompleteTime [
	^ readyToCompleteTime
		ifNotNil: [ releaseTime - readyToCompleteTime ]
		ifNil: [ 0 ms "Make sure it is returned as Duration" ]
]

{ #category : #'as yet unclassified' }
SeqEvent >> waitStartTime [
	^ readyToStartTime
		ifNotNil: [ startTime - readyToStartTime ]
		ifNil: [ 0 ms "Make sure it is returned as Duration" ]
]

{ #category : #'as yet unclassified' }
SeqEvent >> waitTime [
	^self waitStartTime + self waitCompleteTime
]
