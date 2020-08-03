Extension { #name : #Number }

{ #category : #'*Sequence' }
Number >> fps [
	^SeqDuration ms: (1000.0 / self)
]

{ #category : #'*Sequence' }
Number >> ms [
	^SeqDuration ms: self
]
