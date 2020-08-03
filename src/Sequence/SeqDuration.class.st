Class {
	#name : #SeqDuration,
	#superclass : #Object,
	#instVars : [
		'duration'
	],
	#category : #Sequence
}

{ #category : #'instance creation' }
SeqDuration class >> ms: aNumber [ 
	^self new
		duration: aNumber;
		yourself
]

{ #category : #comparing }
SeqDuration >> = aDuration [
	^duration = aDuration duration
]

{ #category : #accessors }
SeqDuration >> duration [
	^duration
]

{ #category : #accessors }
SeqDuration >> duration: aNumberInMS [ 
	duration := aNumberInMS
]

{ #category : #accessing }
SeqDuration >> latency [
	^duration
]
