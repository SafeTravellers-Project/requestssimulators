from pydantic import BaseModel

class InputData(BaseModel):
    transactionId: str
    docType: str
    issuingCountry: str
    lastName: str
    firstNames: str
    docNumber: str
    nationality: str
    birthDate: str
    gender: str
    expirationDate: str
    personalNumber: str

