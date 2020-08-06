Extension { #name : #Number }

{ #category : #'*Sequence' }
Number >> fps [
	^Duration milliSeconds: (1000.0 / self)
]

{ #category : #'*Sequence' }
Number >> ms [
	^Duration milliSeconds: self
]
