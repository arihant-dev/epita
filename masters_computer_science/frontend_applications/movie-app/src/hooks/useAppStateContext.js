import { useContext } from "react"
import { AppStateContext } from "../context/AppStateProvider"

export const useAppStateContext = () => {
  return useContext(AppStateContext);
}