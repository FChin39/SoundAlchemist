from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import audio_devices  # 引用音频设备管理模块

app = FastAPI()

class VcPanelData(BaseModel):
    selectedFile: str = ""
    isConverting: bool = False
    isMonitoring: bool = False
    sliderValue: float = 0.0
    selectedInputDevice: str = ""
    selectedOutputDevice: str = ""

@app.get("/inputDevices", response_model=List[str])
async def get_input_devices():
    try:
        input_devices = audio_devices.get_input_devices()
        return input_devices
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/outputDevices", response_model=List[str])
async def get_output_devices():
    try:
        output_devices = audio_devices.get_output_devices()
        return output_devices
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/")
async def update_data(data: VcPanelData):
    # 在这里处理接收到的数据，例如更新状态或执行相应操作
    print(data)
    return {"message": "Data received"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=6231)
